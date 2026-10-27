/* performance sales view */
CREATE OR REPLACE VIEW vw_order_performance AS
WITH order_items_summary AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS merchandise_sales,
        SUM(freight_value) AS freight_cost
    FROM olist_order_items_dataset
    GROUP BY order_id
),

ranked_reviews AS (
    SELECT
        order_id,
        review_score,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY review_answer_timestamp DESC NULLS LAST,
                     review_creation_date DESC NULLS LAST,
                     review_id DESC
        ) AS rn
    FROM olist_order_reviews_dataset
    WHERE review_score IS NOT NULL
)

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,

    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::DATE AS order_month,

    c.customer_state,
    c.customer_city,

    i.item_count,
    i.merchandise_sales,
    i.freight_cost,

    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    CASE
        WHEN o.order_status <> 'delivered'
          OR o.order_delivered_customer_date IS NULL
          OR o.order_estimated_delivery_date IS NULL
        THEN NULL
        WHEN o.order_delivered_customer_date::DATE >
             o.order_estimated_delivery_date::DATE
        THEN 'Late'
        ELSE 'On-Time'
    END AS delivery_status,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_purchase_timestamp IS NOT NULL
        THEN
            o.order_delivered_customer_date::DATE -
            o.order_purchase_timestamp::DATE
        ELSE NULL
    END AS delivery_days,

    r.review_score

FROM olist_orders_dataset o

LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

LEFT JOIN order_items_summary i
    ON o.order_id = i.order_id

LEFT JOIN ranked_reviews r
    ON o.order_id = r.order_id
   AND r.rn = 1;

/* performance sales view */
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,
    ROUND(
        SUM(merchandise_sales) FILTER (
            WHERE order_status = 'delivered'
        ), 2
    ) AS delivered_sales,
    COUNT(*) FILTER (
        WHERE delivery_status IN ('Late', 'On-Time')
          AND review_score IS NOT NULL
    ) AS reviewed_deliveries
FROM vw_order_performance;

/* category sales view */
CREATE OR REPLACE VIEW vw_category_sales AS
SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::DATE AS sales_month,

    c.customer_state,

    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'uncategorized'
    ) AS product_category,

    ROUND(SUM(oi.price), 2) AS merchandise_sales,

    COUNT(*) AS items_sold,

    COUNT(DISTINCT o.order_id) AS orders_in_group

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY 1, 2, 3;

/* category sales view */
SELECT
    ROUND(SUM(merchandise_sales), 2) AS total_sales,
    SUM(items_sold) AS total_items
FROM vw_category_sales;


