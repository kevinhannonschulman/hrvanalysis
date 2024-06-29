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
        distinct start_week
        , total_mileage
        , case
            when total_mileage < 10 then '0-10'
            when total_mileage between 10 and 20 then '10-20'
            when total_mileage between 20 and 30 then '20-30'
            when total_mileage between 30 and 40 then '30-40'
            when total_mileage > 40 then '> 40' end as mileage_range
        , last_daily_avg_hrv
   from weekly_mileage
)

, final as (
    select 
        start_week
        , mileage_range
        , last_daily_avg_hrv
        , count(start_week) over (partition by mileage_range) as total_runs_in_range
    from ranges
    order by start_week desc
)

select * from final