{{ config(materialized='table') }}

SELECT
    driver_id,
    CASE 
        WHEN MOD(ABS(HASH(driver_id)), 2) = 0 THEN 'A' --driver_id hash>> numbers are assigned to groups A and B
        ELSE 'B'
    END AS experiment_group
FROM {{ ref('stg_drivers') }}