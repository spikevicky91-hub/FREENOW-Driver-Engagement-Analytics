{{ config(materialized='table') }}

SELECT
    experiment_group,
    activity_date,

    AVG(acceptance_rate) AS avg_acceptance_rate,
    AVG(engagement_rate) AS avg_engagement_rate,
    AVG(trips_completed) AS avg_trips,
    AVG(total_earnings) AS avg_earnings

FROM {{ ref('driver_activity') }}
GROUP BY experiment_group, activity_date

