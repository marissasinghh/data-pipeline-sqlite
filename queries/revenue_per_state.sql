-- Goal: customer_state(state), Revenue (total payment_value per state, limited to top 10)
-- reqs:
-- -> order_status must be 'delivered'
-- -> order_delivered_customer_date must be not null
-- -> when an order has multiple payments, sum all (assuming an order is always coming from the same state)

-- What we need:
-- where *j = initial foreign key to join on
--       +j = additional keys to join on
--       agg = to be aggregated
--       req = constraints for query

-- olist_orders_dataset table has the following columns:
-- "order_id" *j
-- "customer_id" +j
-- "order_status" - req
-- "order_delivered_customer_date" - req
-- ex: e481f51cbdc54678b7cc49136f2d6af7,"9ef432eb6251297304e76186b10a928d",delivered,2017-10-02 10:56:33,...

-- olist_order_payments_dataset table has the following columns:
-- "order_id" *j
-- "payment_value" - agg (sum per order before grouping by state)
-- ex: b81ef226f3fe1789b1e8b2acac839d17,1,credit_card,8,99.33

-- olist_customers_dataset table has the following columns:
-- "customer_id" +j
-- "customer_state" - req (two-letter state code used in final output)
-- ex: 9ef432eb6251297304e76186b10a928d,SP,...


WITH payments AS(
    SELECT
        order_id,
        SUM(payment_value) as total_payment_value
    FROM olist_order_payments
    GROUP BY order_id
)
SELECT 
    oc.customer_state as customer_state,
    SUM(p.total_payment_value) as Revenue
FROM olist_orders oo
LEFT JOIN payments p
ON oo.order_id = p.order_id
LEFT JOIN olist_customers oc
ON oo.customer_id = oc.customer_id
WHERE oo.order_status = 'delivered'
AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY oc.customer_state
ORDER BY Revenue DESC
LIMIT 10