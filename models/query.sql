SELECT
    activity_date,

    COUNT(DISTINCT driver_id) AS active_drivers,

    SUM(offers_received) AS total_offers,
    SUM(offers_accepted) AS accepted_offers,

    SUM(trips_completed) AS total_trips,
    SUM(total_earnings) AS total_revenue,

    AVG(acceptance_rate) AS avg_acceptance_rate,
    AVG(engagement_rate) AS avg_engagement_rate

FROM FREENOW_NEW_DB.FREENOW_NEW_SCHEMA.DRIVER_ACTIVITY
GROUP BY activity_date
ORDER BY activity_date;