
WITH month_helper AS (
    SELECT 1 AS month_no UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6 UNION ALL
    SELECT 7 UNION ALL
    SELECT 8 UNION ALL
    SELECT 9 UNION ALL
    SELECT 10 UNION ALL
    SELECT 11 UNION ALL
    SELECT 12
),
delivery_times AS (
    SELECT 
        CAST(STRFTIME('%m', oo.order_purchase_timestamp) AS INTEGER) as month_no,
        CAST(STRFTIME('%Y', oo.order_purchase_timestamp) AS INTEGER) as year,
        AVG(julianday(oo.order_delivered_customer_date) - julianday(oo.order_purchase_timestamp)) as real_delivery_time,
        AVG(julianday(oo.order_estimated_delivery_date) - julianday(oo.order_purchase_timestamp)) as estimated_delivery_time
    FROM (
        SELECT DISTINCT 
            order_id,
            order_delivered_customer_date,
            order_purchase_timestamp,
            order_estimated_delivery_date
        FROM olist_orders 
        WHERE order_status = 'delivered' 
            AND order_delivered_customer_date IS NOT NULL 
            AND order_estimated_delivery_date IS NOT NULL
    ) oo
    GROUP BY month_no, year
)
SELECT 
    printf('%02d', mh.month_no) AS month_no,
    CASE mh.month_no
        WHEN 1 THEN 'Jan'
        WHEN 2 THEN 'Feb'
        WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Apr'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul'
        WHEN 8 THEN 'Aug'
        WHEN 9 THEN 'Sep'
        WHEN 10 THEN 'Oct'
        WHEN 11 THEN 'Nov'
        WHEN 12 THEN 'Dec'
    END AS month,
    MAX(CASE WHEN dt.year = 2016 THEN dt.real_delivery_time ELSE NULL END) AS Year2016_real_time,
    MAX(CASE WHEN dt.year = 2017 THEN dt.real_delivery_time ELSE NULL END) AS Year2017_real_time,
    MAX(CASE WHEN dt.year = 2018 THEN dt.real_delivery_time ELSE NULL END) AS Year2018_real_time,
    MAX(CASE WHEN dt.year = 2016 THEN dt.estimated_delivery_time ELSE NULL END) AS Year2016_estimated_time,
    MAX(CASE WHEN dt.year = 2017 THEN dt.estimated_delivery_time ELSE NULL END) AS Year2017_estimated_time,
    MAX(CASE WHEN dt.year = 2018 THEN dt.estimated_delivery_time ELSE NULL END) AS Year2018_estimated_time
FROM month_helper mh
LEFT JOIN delivery_times dt
ON dt.month_no = mh.month_no
GROUP BY mh.month_no
ORDER BY mh.month_no;