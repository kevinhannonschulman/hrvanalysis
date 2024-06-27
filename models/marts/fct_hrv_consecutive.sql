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
        distinct extract(year from interval_end) as year
        , consecutive_days
        , min(last_daily_avg_hrv) over (partition by extract(year from interval_end), consecutive_days) as min_last_daily_avg_hrv
        , max(last_daily_avg_hrv) over (partition by extract(year from interval_end), consecutive_days) as max_last_daily_avg_hrv
        , avg(last_daily_avg_hrv) over (partition by extract(year from interval_end), consecutive_days) as avg_last_daily_avg_hrv
        , count(*) over (partition by extract(year from workout_date), consecutive_days) as num_interval_count
    from hrv_consecutive_join
    order by year asc, consecutive_days asc
)

select * from final