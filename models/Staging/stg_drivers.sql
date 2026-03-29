{{ config(materialized='view') }}

WITH cleaned AS (

    SELECT
        LOWER(id) AS driver_id,

        CASE 
            WHEN UPPER(country) IN ('FR', 'FRANCE') THEN 'FRANCE'
            ELSE UPPER(country)
        END AS country,

        rating,
        rating_count,

        TO_TIMESTAMP(date_registration) AS registration_ts,

        CAST(receive_marketing AS BOOLEAN) AS receive_marketing

    FROM {{ source('raw', 'freenow_drivers') }}

),

deduplicated AS (

    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY driver_id
                ORDER BY registration_ts DESC
            ) AS rn
        FROM cleaned
    )
    WHERE rn = 1

)

SELECT * FROM deduplicated