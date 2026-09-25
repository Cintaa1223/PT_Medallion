SELECT
    c.customer_id,
    c.customer_name,
    c.customer_address,
    c.customer_phone,
    c.account_balance,
    c.market_segment,
    n.nation_id,
    n.nation_name,
    n.region_id,
    n.region_name
FROM {{ ref('silver_customer') }} c
LEFT JOIN {{ ref('silver_nation') }} n
    ON c.nation_id = n.nation_id