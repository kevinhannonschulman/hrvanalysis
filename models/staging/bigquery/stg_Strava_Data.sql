with source as (
    select * from {{ source ('dbt_hrvanalysis', 'Strava_Data') }}
)

, final as (
    select
        format_timestamp('%F %T', start_date_local) as workout_start_eastern
        , (distance * .000621) as miles
        , (moving_time / 60) as minutes
        , (total_elevation_gain * 3.281) as elevation_gain_ft
        , average_heartrate
        , max_heartrate
    from source
    where average_heartrate is not null
)

select * from final order by workout_start_eastern desc