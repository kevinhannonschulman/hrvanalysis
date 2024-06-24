with tablejoin as (
    select * from {{ ref('int_strava_apple_join')}}
)

, ranges as (
    select
        workout_date
        , elev_gain_ft
        , case
            when elev_gain_ft between 0 and 100 then '0-100'
            when elev_gain_ft between 100 and 200 then '100-200'
            when elev_gain_ft between 200 and 300 then '200-300'
            when elev_gain_ft between 300 and 400 then '300-400'
            when elev_gain_ft between 400 and 500 then '400-500'
            when elev_gain_ft between 500 and 600 then '500-600' end as elev_gain_range
        , daily_avg_hrv
    from tablejoin
    order by workout_date desc
)

, final as (
    select
        distinct extract(year from workout_date) as year
        , elev_gain_range
        , min(daily_avg_hrv) over (partition by extract(year from workout_date), elev_gain_range) as min_daily_hrv_elev_range
        , max(daily_avg_hrv) over (partition by extract(year from workout_date), elev_gain_range) as max_daily_hrv_elev_range
        , avg(daily_avg_hrv) over (partition by extract(year from workout_date), elev_gain_range) as avg_daily_hrv_elev_range
        , count(daily_avg_hrv) over (partition by extract(year from workout_date), elev_gain_range) as num_runs_in_range
    from ranges
    where daily_avg_hrv is not null
    order by year asc, elev_gain_range asc
)

select * from final