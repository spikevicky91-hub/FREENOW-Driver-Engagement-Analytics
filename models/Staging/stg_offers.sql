{{ config(materialized='view') }}

WITH cleaned AS (

    SELECT
        LOWER(id) AS offer_id,
        LOWER(bookingid) AS booking_id,
        LOWER(driverid) AS driver_id,

        TO_TIMESTAMP(datecreated) AS offer_ts,
        TO_DATE(datecreated) AS offer_date,

        TRY_TO_NUMBER(routedistance) AS routedistance,

        UPPER(state) AS state,

        CAST(driverread AS BOOLEAN) AS driver_read

    FROM {{ source('raw', 'freenow_offers') }}

),

deduplicated AS (

    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY offer_id
                ORDER BY offer_ts DESC
            ) AS rn
        FROM cleaned
    )
    WHERE rn = 1

)

SELECT * FROM deduplicated