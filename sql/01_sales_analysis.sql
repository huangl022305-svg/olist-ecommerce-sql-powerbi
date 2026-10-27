CREATE TABLE olist_customers_dataset (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);

CREATE TABLE olist_orders_dataset (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE olist_order_items_dataset (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE olist_products_dataset (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE olist_order_reviews_dataset (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

/* highest delivered order by states */
SELECT c.customer_state, COUNT(*) as delivered_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY delivered_orders DESC
LIMIT 10;

/* total sales, total orders, total items, average order value */
SELECT
    ROUND(SUM(oi.price), 2) AS total_sales,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(*) AS total_items,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id), 2
    ) AS average_order_value
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

/* monthly sales trend */
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE
        AS sales_month,
    ROUND(SUM(oi.price), 2) AS monthly_sales,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 1;

/* month-over-month sales growth */
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::DATE
            AS sales_month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-08-01'
    GROUP BY 1
),

sales_growth AS (
    SELECT
        sales_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    sales_month,
    revenue,
    previous_month_revenue,
    ROUND(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM sales_growth
ORDER BY sales_month;

/* Top 10 product categories by revenue */
SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'uncategorized'
    ) AS product_category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY total_revenue DESC
LIMIT 10;

/* delivery performance by state */
SELECT
    c.customer_state,
    COUNT(*) AS total_deliveries,

    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date::DATE >
              o.order_estimated_delivery_date::DATE
    ) AS late_deliveries,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date::DATE >
                  o.order_estimated_delivery_date::DATE
        ) / COUNT(*),
        2
    ) AS late_delivery_rate,

    ROUND(
        AVG(
            o.order_delivered_customer_date::DATE -
            o.order_purchase_timestamp::DATE
        ), 1
    ) AS avg_delivery_days

FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL

GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY late_delivery_rate DESC
LIMIT 10;

/* delivery delay vs customer satisfaction */
WITH ranked_reviews AS (
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
),

delivery_reviews AS (
    SELECT
        o.order_id,
        r.review_score,
        CASE
            WHEN o.order_delivered_customer_date::DATE >
                 o.order_estimated_delivery_date::DATE
            THEN 'Late'
            ELSE 'On-Time'
        END AS delivery_status
    FROM olist_orders_dataset o
    JOIN ranked_reviews r
        ON o.order_id = r.order_id
       AND r.rn = 1
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    delivery_status,
    COUNT(*) AS reviewed_orders,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    COUNT(*) FILTER (
        WHERE review_score <= 2
    ) AS low_rating_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE review_score <= 2
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS low_rating_rate_pct
FROM delivery_reviews
GROUP BY delivery_status
ORDER BY delivery_status;
