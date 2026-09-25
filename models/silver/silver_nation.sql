SELECT
    n.n_nationkey AS nation_id,
    TRIM(n.n_name) AS nation_name,
    r.region_id,
    r.region_name
FROM {{ ref('bronze_nation') }} n
LEFT JOIN {{ ref('silver_region') }} r
    ON n.n_regionkey = r.region_id
WHERE n.n_nationkey IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY n.n_nationkey
    ORDER BY n.n_nationkey
) = 1