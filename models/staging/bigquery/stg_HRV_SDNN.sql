with source as(
    select * from {{ source('dbt_hrvanalysis', 'HRV_SDNN') }}
)

, reformat as (
    select
        format_timestamp('%F %T', creationDate, 'America/New_York') as timestamp_eastern
        , value as HRV_ms
    from source
)

, final as (
    select
        timestamp_eastern
        , HRV_ms
        , avg(HRV_ms) over (partition by extract(date from timestamp(timestamp_eastern))) as daily_avg_hrv
    from reformat
)

select * from final order by timestamp_eastern desc