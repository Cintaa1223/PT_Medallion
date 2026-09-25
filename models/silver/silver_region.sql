SELECT
    r_regionkey AS region_id,
    TRIM(r_name) AS region_name,
    TRIM(r_comment) AS region_comment
FROM {{ ref('bronze_region') }}
WHERE r_regionkey IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY r_regionkey
    ORDER BY r_regionkey
) = 1