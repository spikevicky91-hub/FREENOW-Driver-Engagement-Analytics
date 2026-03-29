{{ config(
    materialized='table',
    cluster_by=['activity_date']
) }}

-- Created the Date spine based on question asked
WITH date_spine AS (

    SELECT DATEADD(DAY, SEQ4(), '2021-06-01') AS activity_date
    FROM TABLE(GENERATOR(ROWCOUNT => 14))

),

-- Created Driver base to get Distinct users
driver_base AS (

    SELECT DISTINCT driver_id 
    FROM {{ ref('stg_drivers') }}

),

-- Fetching Driver x Date (ensures full coverage)
driver_dates AS (

    SELECT 
        d.driver_id,
        ds.activity_date
    FROM driver_base d
    CROSS JOIN date_spine ds

),

-- Offers aggregation
offers_agg AS (

    SELECT
        driver_id,
        offer_date,

        COUNT(*) AS offers_received,
        SUM(IFF(driver_read,1,0)) AS offers_read,
        SUM(IFF(state='ACCEPTED',1,0)) AS offers_accepted,
        AVG(routedistance) AS avg_distance

    FROM {{ ref('stg_offers') }}
    GROUP BY driver_id, offer_date

),

-- 5. Bookings aggregation
bookings_agg AS (

    SELECT
        driver_id,
        request_date,

        COUNT(*) AS trips_completed,
        SUM(estimated_route_fare) AS total_earnings

    FROM {{ ref('stg_bookings') }}
    WHERE status = 'SUCCESS'
    GROUP BY driver_id, request_date

)

-- 6. Final table
SELECT
    dd.driver_id,
    dd.activity_date,

    -- Offer metrics
    COALESCE(o.offers_received, 0) AS offers_received,
    COALESCE(o.offers_read, 0) AS offers_read,
    COALESCE(o.offers_accepted, 0) AS offers_accepted,

    -- Booking metrics
    COALESCE(b.trips_completed, 0) AS trips_completed,
    COALESCE(b.total_earnings, 0) AS total_earnings,

    -- Derived KPIs
    CASE 
        WHEN o.offers_received > 0 
        THEN o.offers_accepted * 1.0 / o.offers_received 
        ELSE 0 
    END AS acceptance_rate,

    CASE 
        WHEN o.offers_received > 0 
        THEN o.offers_read * 1.0 / o.offers_received 
        ELSE 0 
    END AS engagement_rate

FROM driver_dates dd
LEFT JOIN offers_agg o
    ON dd.driver_id = o.driver_id
    AND dd.activity_date = o.offer_date

LEFT JOIN bookings_agg b
    ON dd.driver_id = b.driver_id
    AND dd.activity_date = b.request_date