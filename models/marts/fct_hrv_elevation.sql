with tablejoin as (
    select * from {{ ref('int_strava_apple_join')}}
)

, ranges as (
    select
        workout_date
        , elev_gain_ft
        , case
            when elev_gain_ft between 0 and 100 then 1
            when elev_gain_ft between 100 and 200 then 2
            when elev_gain_ft between 200 and 300 then 3
            when elev_gain_ft between 300 and 400 then 4
            when elev_gain_ft between 400 and 500 then 5
            when elev_gain_ft between 500 and 600 then 6 end as elev_gain_range
        , daily_avg_hrv
    from tablejoin
    order by workout_date desc
)

, final as (
    select
        distinct extract(year from workout_date) as year
        , elev_gain_range
        , min(daily_avg_hrv) over (partition by extract(year from workout_date), elev_gain_range) as min_elev_hrv
        , max(daily_avg_hrv) over (partition by extract(year from workout_date), elev_gain_range) as max_elev_hrv
        , avg(daily_avg_hrv) over (partition by extract(year from workout_date), elev_gain_range) as avg_elev_hrv
    from ranges
    where daily_avg_hrv is not null
    order by year asc, elev_gain_range asc
)

select * from final