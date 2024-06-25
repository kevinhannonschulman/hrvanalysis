with tablejoin as (
    select * from {{ ref('int_strava_apple_join')}}
)

, weeks as (
    select
        workout_date
        , miles
        , daily_avg_hrv
        , date_trunc(workout_date, week) as start_week
    from tablejoin
)

, weekly_mileage as (
    select
        workout_date
        , start_week
        , sum(miles) over (partition by start_week) as total_mileage
        , daily_avg_hrv
        , last_value(daily_avg_hrv) over (partition by start_week order by workout_date asc rows between unbounded preceding and unbounded following) as last_daily_avg_hrv
    from weeks
    order by workout_date desc, start_week desc
)

, ranges as (
    select
        start_week
        , total_mileage
        , case
            when total_mileage < 10 then '< 10'
            when total_mileage between 10 and 20 then '10-20'
            when total_mileage between 20 and 30 then '20-30'
            when total_mileage between 30 and 40 then '30-40'
            when total_mileage > 40 then '> 40' end as mileage_range
        , daily_avg_hrv
        , last_daily_avg_hrv
   from weekly_mileage
)

, final as (
    select
        distinct extract(year from start_week) as year
        , mileage_range
        , min(last_daily_avg_hrv) over (partition by extract(year from start_week), mileage_range) as min_last_daily_avg_hrv
        , max(last_daily_avg_hrv) over (partition by extract(year from start_week), mileage_range) as max_last_daily_avg_hrv
        , avg(last_daily_avg_hrv) over (partition by extract(year from start_week), mileage_range) as avg_last_daily_avg_hrv
        , avg(daily_avg_hrv) over (partition by extract(year from start_week), mileage_range) as avg_daily_hrv_mileage_range
        , avg(daily_avg_hrv) over (partition by extract(year from start_week)) as avg_yearly_hrv
        , count(distinct start_week) over (partition by extract(year from start_week), mileage_range) as num_interval_count
    from ranges
    where daily_avg_hrv is not null
    order by year asc, mileage_range asc
)

select * from final