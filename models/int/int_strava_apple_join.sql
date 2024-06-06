with hrv_sdnn as (
    select * from {{ ref('stg_HRV_SDNN')}}
)

, strava as (
    select * from {{ ref('stg_Strava_Data')}}
)

, final as (
    select
        distinct strava.workout_date
        , strava.miles
        , strava.minutes
        , strava.elevation_gain_ft as elev_gain_ft
        , hrv_sdnn.daily_avg_hrv as daily_avg_hrv
    from strava
    inner join hrv_sdnn on strava.workout_date = date(hrv_sdnn.timestamp_eastern)
    order by workout_date asc
)

select * from final