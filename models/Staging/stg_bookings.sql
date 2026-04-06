{{ config(materialized='view') }}

WITH cleaned AS (

    SELECT
        LOWER(id) AS booking_id,
        LOWER(id_driver) AS driver_id,

        TO_TIMESTAMP(request_date) AS request_ts,
        TO_DATE(request_date) AS request_date,

        UPPER(status) AS status,

        TRY_TO_NUMBER(estimated_route_fare) AS estimated_route_fare 

    FROM {{ source('raw', 'freenow_bookings') }} --raw ingestion table

),

deduplicated AS (

    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY booking_id
                ORDER BY request_ts DESC
            ) AS rn
        FROM cleaned
    )
    WHERE rn = 1 --latest record for each booking_id, in case of duplicates

)
SELECT * FROM deduplicated