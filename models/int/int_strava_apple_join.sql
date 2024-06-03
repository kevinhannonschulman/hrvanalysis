with hrv_sdnn as (
    select * from {{ ref('stg_HRV_SDNN')}}
)

, strava as (
    select * from {{ ref('stg_Strava_Data')}}
)

, final as (
    select
        distinct date(strava.workout_start_eastern) as workout_date
        , strava.miles
        , strava.minutes
        , strava.elevation_gain_ft as elev_gain_ft
        , hrv_sdnn.daily_avg_hrv as daily_avg_hrv
    from strava
    left join hrv_sdnn on date(strava.workout_start_eastern) = date(hrv_sdnn.timestamp_eastern)
    order by workout_date desc
)

select * from final