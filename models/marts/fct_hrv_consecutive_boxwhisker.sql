with tablejoin as (
    select * from {{ ref('int_strava_apple_join')}}
)

, datecount as (
    select
        workout_date
        , dense_rank () over (order by workout_date) as rnk
    from tablejoin
    order by rnk asc
)

, dategroups as (
    select
        workout_date
        , (date(workout_date) - (interval 1 day) * rnk) as date_group
    from datecount
)

, consecutive as (
    select
        min(workout_date) as interval_start
        , max(workout_date) as interval_end
        , 1 + date_diff(max(workout_date), min(workout_date), day) as consecutive_days
    from dategroups
    group by date_group
    order by interval_start desc
)

, hrv_values as (
    select
        workout_date
        , daily_avg_hrv
    from tablejoin
)

, hrv_consecutive_join as (
    select
        hrv_values.workout_date
        , hrv_values.daily_avg_hrv as last_daily_avg_hrv
        , consecutive.interval_start
        , consecutive.interval_end
        , consecutive.consecutive_days
    from hrv_values
    inner join consecutive on hrv_values.workout_date = consecutive.interval_end
    order by workout_date desc
)

, final as (
    select 
        workout_date
        , consecutive_days
        , last_daily_avg_hrv
        , count(workout_date) over (partition by consecutive_days) as total_intervals_in_range
    from hrv_consecutive_join
    order by workout_date desc
)

select * from final