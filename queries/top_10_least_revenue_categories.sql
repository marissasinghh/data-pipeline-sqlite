-- Exactly same as top_10_revenue_categories.sql, but with Revenue in ascending order!


WITH payments AS (
    SELECT 
        order_id, 
        SUM(payment_value) as total_payment_value
    FROM olist_order_payments
    GROUP BY order_id
)
SELECT 
    pct.product_category_name_english as Category,
    COUNT(DISTINCT oo.order_id) as Num_order,
    SUM(p.total_payment_value) as Revenue

FROM olist_orders oo
LEFT JOIN olist_order_items ooi
ON oo.order_id = ooi.order_id
LEFT JOIN olist_products op
ON ooi.product_id = op.product_id
LEFT JOIN product_category_name_translation pct
ON op.product_category_name = pct.product_category_name
LEFT JOIN payments p
ON oo.order_id = p.order_id

WHERE oo.order_status = 'delivered'
AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY pct.product_category_name_english
HAVING  pct.product_category_name_english IS NOT NULL

ORDER BY Revenue ASC
LIMIT 10