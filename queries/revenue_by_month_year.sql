-- Goal: month_no (01-12), month (Jan/Feb/...), Year2016, Year2017, Year2018
-- reqs:
-- -> order_status must be 'delivered'
-- -> order_delivered_customer_date must be not null
-- -> keep only one payment record per order_id (smallest payment_value)
-- -> months with no revenue should return 0.00

-- What we need:
-- where *j = initial foreign key to join on
--       +j = additional keys to join on
--       agg = to be aggregated
--       req = constraints for query

-- olist_order_payments_dataset table has the following columns:
-- "order_id" *j
-- "payment_value" - agg (after deduplicating per order)
-- ex: b81ef226f3fe1789b1e8b2acac839d17,1,credit_card,8,99.33

-- olist_orders_dataset table has the following columns:
-- "order_id" *j
-- "order_status" - req
-- "order_delivered_customer_date" - req (used for year/month extraction)
-- ex: e481f51cbdc54678b9cc49136f2d6af7,"9ef432eb6251297304e76186b10a928d",delivered,2017-10-02 10:56:33,...


WITH min_payment_value AS (
    SELECT 
        order_id,
        MIN(payment_value) as min_payment_value
    FROM olist_order_payments 
    GROUP BY order_id
), 
month_helper AS (
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
total_revenue_by_yearmonth AS (
    SELECT 
        CAST(STRFTIME('%Y', oo.order_delivered_customer_date) AS INTEGER) as year,
        CAST(STRFTIME('%m', oo.order_delivered_customer_date) AS INTEGER) as month,
        SUM(min_payment_value) as total_revenue
    FROM min_payment_value mpv 
    LEFT JOIN olist_orders oo 
    ON mpv.order_id = oo.order_id
    WHERE oo.order_status = 'delivered' AND oo.order_delivered_customer_date IS NOT NULL
    GROUP BY year, month
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
    COALESCE(SUM(CASE WHEN trby.year = 2016 THEN trby.total_revenue ELSE 0 END), 0.00) AS Year2016,
    COALESCE(SUM(CASE WHEN trby.year = 2017 THEN trby.total_revenue ELSE 0 END), 0.00) AS Year2017,
    COALESCE(SUM(CASE WHEN trby.year = 2018 THEN trby.total_revenue ELSE 0 END), 0.00) AS Year2018
FROM month_helper mh
LEFT JOIN total_revenue_by_yearmonth trby
    ON trby.month = mh.month_no
GROUP BY mh.month_no
ORDER BY mh.month_no;