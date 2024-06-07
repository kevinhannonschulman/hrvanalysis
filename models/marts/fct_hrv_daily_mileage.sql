with tablejoin as (
    select * from {{ ref('int_strava_apple_join')}}
)

, ranges as (
    select
        workout_date
        , case
            when miles between 0 and 4 then 1
            when miles between 4 and 5 then 2
            when miles between 5 and 6 then 3
            when miles between 6 and 7 then 4
            when miles between 7 and 8 then 5
            when miles between 8 and 9 then 6
            when miles between 9 and 10 then 7
            when miles > 10 then 8 end as mileage_range
        , daily_avg_hrv
    from tablejoin
    order by workout_date desc
)

, final as (
    select
        distinct extract(year from workout_date) as year
        , mileage_range
        , min(daily_avg_hrv) over (partition by extract(year from workout_date), mileage_range) as min_daily_hrv_mileage_range
        , max(daily_avg_hrv) over (partition by extract(year from workout_date), mileage_range) as max_daily_hrv_mileage_range
        , avg(daily_avg_hrv) over (partition by extract(year from workout_date), mileage_range) as avg_daily_hrv_mileage_range
        , count(daily_avg_hrv) over (partition by extract(year from workout_date), mileage_range) as num_runs_in_range
    from ranges
    where daily_avg_hrv is not null
    order by year asc, mileage_range asc
)

select * from final