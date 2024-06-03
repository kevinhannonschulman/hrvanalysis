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
    from weeks
    order by start_week desc
)

, ranges as (
    select
        start_week
        , total_mileage
        , case
            when total_mileage between 10 and 20 then 1
            when total_mileage between 20 and 30 then 2
            when total_mileage between 30 and 40 then 3
            when total_mileage > 40 then 4 end as mileage_range
        , daily_avg_hrv
   from weekly_mileage
)

, final as (
    select
        distinct extract(year from start_week) as year
        , mileage_range
        , min(daily_avg_hrv) over (partition by extract(year from start_week), mileage_range) as min_mileagerange_hrv
        , max(daily_avg_hrv) over (partition by extract(year from start_week), mileage_range) as max_mileagerange_hrv
        , avg(daily_avg_hrv) over (partition by extract(year from start_week), mileage_range) as avg_mileagerange_hrv
    from ranges
    where daily_avg_hrv is not null
    order by year asc, mileage_range asc
)

select * from final