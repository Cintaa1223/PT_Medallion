SELECT
    c_custkey      AS customer_id,
    TRIM(c_name)   AS customer_name,
    TRIM(c_address) AS customer_address,
    c_nationkey    AS nation_id,
    TRIM(c_phone)  AS customer_phone,
    c_acctbal      AS account_balance,
    TRIM(c_mktsegment) AS market_segment,
    TRIM(c_comment) AS customer_comment
FROM {{ ref('bronze_customer') }}
WHERE c_custkey IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY c_custkey
    ORDER BY c_custkey
) = 1