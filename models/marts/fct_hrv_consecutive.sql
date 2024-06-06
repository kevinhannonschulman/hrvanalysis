with tablejoin as (
    select * from {{ ref('int_strava_apple_join')}}
)

, datecount as (
    select
        workout_date
        , daily_avg_hrv
        , dense_rank () over (order by workout_date) as rnk
    from tablejoin
    order by rnk asc
)

, dategroups as (
    select
        workout_date
        , (date(workout_date) - (interval 1 day) * rnk) as date_group
        , daily_avg_hrv
    from datecount
)

, consecutive as (
    select
        min(workout_date) as interval_start
        , max(workout_date) as interval_end
        , 1 + date_diff(max(workout_date), min(workout_date), day) as consecutive_days
        , avg(daily_avg_hrv) as interval_avg_hrv
    from dategroups
    group by date_group
    order by interval_start desc
)

, final as (
    select
        distinct extract (year from interval_end) as year
        , consecutive_days
        , min(interval_avg_hrv) over (partition by extract(year from interval_end), consecutive_days) as min_hrv_interval
        , max(interval_avg_hrv) over (partition by extract(year from interval_end), consecutive_days) as max_hrv_interval
        , avg(interval_avg_hrv) over (partition by extract(year from interval_end), consecutive_days) as avg_hrv_interval
        , count(interval_avg_hrv) over (partition by extract(year from interval_end), consecutive_days) as num_runs
    from consecutive
    where interval_avg_hrv is not null
    order by year asc, consecutive_days asc
)

select * from final