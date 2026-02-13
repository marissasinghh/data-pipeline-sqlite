
SELECT customer_state AS State,
    CAST(
        AVG(
            julianday(Date_est_del) - julianday(Date_delivered)
            ) AS int
    ) AS Delivery_Difference
FROM (
    SELECT order_id,
        customer_id,
        STRFTIME('%Y-%m-%d', order_delivered_customer_date) AS Date_delivered,
        STRFTIME('%Y-%m-%d', order_estimated_delivery_date) AS Date_est_del
    FROM olist_orders
    WHERE order_status == 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    ) AS A
    JOIN (
        SELECT customer_id,
            customer_state
        FROM olist_customers
    ) AS B ON A.customer_id = B.customer_id
group by State
order by Delivery_Difference 
