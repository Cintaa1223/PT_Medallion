SELECT
    o_orderkey   AS order_id,
    o_custkey    AS customer_id,
    o_orderdate  AS order_date,
    o_totalprice AS order_total_price,
    CASE o_orderstatus
        WHEN 'O' THEN 'Open'
        WHEN 'F' THEN 'Fulfilled'
        WHEN 'P' THEN 'Pending'
        ELSE 'Unknown'
    END AS order_status,
    TRIM(o_orderpriority) AS order_priority,
    TRIM(o_clerk) AS clerk,
    o_shippriority AS ship_priority,
    TRIM(o_comment) AS order_comment
FROM {{ ref('bronze_orders') }}
WHERE o_orderkey IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY o_orderkey
    ORDER BY o_orderkey
) = 1