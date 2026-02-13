-- Goal: Category (in eng), Num_order (per category), Revenue (sum of payment values per category) 
-- reqs: 
-- -> order_status needs to be delivered 
-- -> Category and delivery date need to be not null
-- -> If there are orders with multiple product categories, sum all categories 

-- What we need:
-- where *j = initial foreign key to join on
--       +j = additional foreign keys to join on
--       agg = to be aggregated
--       req = constraints for query 

-- olist_orders_dataset table has the following columns:
-- "order_id" *j
-- "order_status" - req
-- "order_delivered_customer_date" - req
-- ex: e481f51cbdc54678b7cc49136f2d6af7,"9ef432eb6251297304e76186b10a928d",delivered,2017-10-02 10:56:33,2017-10-02 11:07:15,2017-10-04 19:55:00,2017-10-10 21:25:13,2017-10-18 00:00:00

-- olist_order_payments table has the following columns:
-- "order_id" *j
-- "payment_value" - agg
-- ex: b81ef226f3fe1789b1e8b2acac839d17,1,credit_card,8,99.33

-- olist_order_items table has the following columns:
-- "order_id" *j
-- "product_id" +j
-- ex: e481f51cbdc54678b7cc49136f2d6af7,b81ef226f3fe1789b1e8b2acac839d17,1,100.00,10.00

-- olist_products_dataset table has the following columns:
-- "product_id" +j
-- "product_category_name" +j
-- ex: b81ef226f3fe1789b7cc49136f2d6af7,beleza_saude,10,100,10,100.00,10.00,10.00,10.00

-- product_category_name_translation table has the following columns:
-- "product_category_name" +j
-- "product_category_name_english" - req
-- ex: beleza_saude,Beauty & Health


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
INNER JOIN olist_order_items ooi
ON oo.order_id = ooi.order_id
INNER JOIN olist_products op
ON ooi.product_id = op.product_id
INNER JOIN product_category_name_translation pct
ON op.product_category_name = pct.product_category_name
INNER JOIN payments p
ON oo.order_id = p.order_id

WHERE oo.order_status = 'delivered'
AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY pct.product_category_name_english

ORDER BY Revenue DESC
LIMIT 10