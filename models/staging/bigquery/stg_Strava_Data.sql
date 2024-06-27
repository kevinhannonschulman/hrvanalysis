with source as (
    select * from {{ source ('dbt_hrvanalysis', 'Strava_Data') }}
)

, final as (
    select
        date(start_date_local) as workout_date
        , (distance * .000621) as miles
        , (moving_time / 60) as minutes
        , (total_elevation_gain * 3.281) as elevation_gain_ft
    from source
)

select * from final order by workout_date desc