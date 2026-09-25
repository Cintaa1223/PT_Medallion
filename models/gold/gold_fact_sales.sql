SELECT
    li.order_id,
    li.line_number,
    o.customer_id,
    o.order_date            AS date_id,
    li.part_id,
    li.supplier_id,
    li.quantity,
    li.extended_price,
    li.discount,
    li.tax,
    li.net_revenue,
    li.gross_revenue,
    li.return_flag,
    li.line_status
FROM {{ ref('silver_lineitem') }} li
LEFT JOIN {{ ref('silver_orders') }} o
    ON li.order_id = o.order_id