SELECT
    l_orderkey    AS order_id,
    l_linenumber  AS line_number,
    l_partkey     AS part_id,
    l_suppkey     AS supplier_id,
    l_quantity    AS quantity,
    l_extendedprice AS extended_price,
    l_discount    AS discount,
    l_tax         AS tax,
    l_extendedprice * (1 - l_discount) AS net_revenue,
    l_extendedprice * (1 - l_discount) * (1 + l_tax) AS gross_revenue,
    l_shipdate    AS ship_date,
    l_commitdate  AS commit_date,
    l_receiptdate AS receipt_date,
    TRIM(l_returnflag) AS return_flag,
    TRIM(l_linestatus)  AS line_status
FROM {{ ref('bronze_lineitem') }}
WHERE l_orderkey IS NOT NULL
    AND l_quantity > 0
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY l_orderkey, l_linenumber
    ORDER BY l_orderkey
) = 1