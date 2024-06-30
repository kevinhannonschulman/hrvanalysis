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
        workout_date
        , elev_gain_range
        , daily_avg_hrv
        , count(workout_date) over (partition by elev_gain_range) as total_runs_in_range
    from ranges
    order by workout_date desc
)

select * from final