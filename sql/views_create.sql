-- -----------------------------
-- 1) EXECUTIVE SUMMARY
-- -----------------------------
CREATE OR REPLACE VIEW vw_executive_summary AS
WITH order_summary AS (
    SELECT
        o.order_id,
        o.order_status,
        COALESCE(SUM(i.item_total_value), 0) AS order_gmv
    FROM olist_orders o
    LEFT JOIN olist_order_items i
        ON o.order_id = i.order_id
    GROUP BY o.order_id, o.order_status
)
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    ROUND(
        (
            SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END)::numeric
            / COUNT(*)
        ) * 100,
        2
    ) AS delivery_rate_pct,
    ROUND(SUM(order_gmv)::numeric, 2) AS total_gmv,
    ROUND(AVG(order_gmv)::numeric, 2) AS aov
FROM order_summary;


-- -----------------------------
-- 2) MONTHLY SALES TREND
-- -----------------------------
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month_start,
    TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM') AS month_label,
    EXTRACT(YEAR FROM o.order_purchase_timestamp)::int AS order_year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp)::int AS order_month,
    COUNT(DISTINCT o.order_id) AS monthly_orders,
    ROUND(SUM(i.item_total_value)::numeric, 2) AS monthly_gmv
FROM olist_orders o
JOIN olist_order_items i
    ON o.order_id = i.order_id
GROUP BY
    DATE_TRUNC('month', o.order_purchase_timestamp),
    TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM'),
    EXTRACT(YEAR FROM o.order_purchase_timestamp),
    EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY month_start;


-- -----------------------------
-- 3) GEOGRAPHIC PERFORMANCE
-- -----------------------------
CREATE OR REPLACE VIEW vw_geographic_performance AS
WITH order_level AS (
    SELECT
        o.order_id,
        c.customer_state AS state,
        AVG(r.review_score) AS review_score,
        EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) AS delivery_days,
        CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
            ELSE 0
        END AS is_late
    FROM olist_orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    LEFT JOIN olist_order_reviews r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        o.order_id,
        c.customer_state,
        o.order_delivered_customer_date,
        o.order_purchase_timestamp,
        o.order_estimated_delivery_date
),
order_gmv AS (
    SELECT
        order_id,
        SUM(item_total_value) AS order_gmv
    FROM olist_order_items
    GROUP BY order_id
)
SELECT
    ol.state,
    COUNT(*) AS total_orders,
    ROUND(SUM(og.order_gmv)::numeric, 2) AS total_gmv,
    ROUND(AVG(ol.review_score)::numeric, 2) AS avg_review_score,
    ROUND(AVG(ol.delivery_days)::numeric, 2) AS avg_delivery_days,
    ROUND(AVG(ol.is_late)::numeric * 100, 2) AS late_delivery_rate_pct
FROM order_level ol
LEFT JOIN order_gmv og
    ON ol.order_id = og.order_id
GROUP BY ol.state
ORDER BY total_orders DESC;


-- -----------------------------
-- 4) CATEGORY INSIGHTS
-- -----------------------------
CREATE OR REPLACE VIEW vw_category_insights AS
SELECT
    COALESCE(p.product_category_name_english, 'Unknown') AS category,
    COUNT(DISTINCT i.order_id) AS total_orders,
    ROUND(SUM(i.item_total_value)::numeric, 2) AS total_gmv,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    ROUND(AVG(i.freight_value)::numeric, 2) AS avg_freight,
    ROUND(
        AVG(i.freight_value / NULLIF(i.item_total_value, 0))::numeric * 100,
        2
    ) AS avg_freight_ratio_pct
FROM olist_order_items i
JOIN olist_products p
    ON i.product_id = p.product_id
LEFT JOIN olist_order_reviews r
    ON i.order_id = r.order_id
GROUP BY COALESCE(p.product_category_name_english, 'Unknown')
ORDER BY total_gmv DESC;


-- -----------------------------
-- 5) DELIVERY STATUS VS REVIEWS
-- -----------------------------
CREATE OR REPLACE VIEW vw_delivery_status_review AS
SELECT
    CASE
        WHEN o.is_late = TRUE THEN 'Late'
        ELSE 'On-time'
    END AS delivery_status,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    ROUND(
        (
            SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END)::numeric
            / COUNT(o.order_id)
        ) * 100,
        2
    ) AS negative_review_rate_pct
FROM olist_orders o
JOIN olist_order_reviews r
    ON o.order_id = r.order_id
GROUP BY
    CASE
        WHEN o.is_late = TRUE THEN 'Late'
        ELSE 'On-time'
    END
ORDER BY delivery_status;


-- -----------------------------
-- 6) DELIVERY TIME BINS
-- -----------------------------
CREATE OR REPLACE VIEW vw_delivery_bins AS
SELECT
    CASE
        WHEN o.delivery_days <= 7 THEN '0-7 Days'
        WHEN o.delivery_days <= 14 THEN '8-14 Days'
        WHEN o.delivery_days <= 21 THEN '15-21 Days'
        ELSE 'Over 21 Days'
    END AS delivery_window,
    CASE
        WHEN o.delivery_days <= 7 THEN 1
        WHEN o.delivery_days <= 14 THEN 2
        WHEN o.delivery_days <= 21 THEN 3
        ELSE 4
    END AS delivery_window_sort,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM olist_orders o
JOIN olist_order_reviews r
    ON o.order_id = r.order_id
WHERE o.delivery_days IS NOT NULL
GROUP BY
    CASE
        WHEN o.delivery_days <= 7 THEN '0-7 Days'
        WHEN o.delivery_days <= 14 THEN '8-14 Days'
        WHEN o.delivery_days <= 21 THEN '15-21 Days'
        ELSE 'Over 21 Days'
    END,
    CASE
        WHEN o.delivery_days <= 7 THEN 1
        WHEN o.delivery_days <= 14 THEN 2
        WHEN o.delivery_days <= 21 THEN 3
        ELSE 4
    END
ORDER BY delivery_window_sort;


-- -----------------------------
-- 7) SELLER DETAIL VIEW
-- Optional but useful for drill-through
-- -----------------------------
CREATE OR REPLACE VIEW vw_seller_details AS
WITH seller_order_metrics AS (
    SELECT
        i.seller_id,
        i.order_id,
        SUM(i.price) AS seller_order_gmv,
        AVG(i.freight_value) AS avg_freight_value,
        AVG(r.review_score) AS review_score,
        MAX(CASE WHEN o.is_late = TRUE THEN 1 ELSE 0 END) AS is_late
    FROM olist_order_items i
    JOIN olist_orders o
        ON i.order_id = o.order_id
    LEFT JOIN olist_order_reviews r
        ON i.order_id = r.order_id
    GROUP BY i.seller_id, i.order_id
),
seller_metrics AS (
    SELECT
        seller_id,
        SUM(seller_order_gmv) AS total_gmv,
        COUNT(*) AS total_orders,
        AVG(avg_freight_value) AS avg_freight_value,
        AVG(review_score) AS avg_review_score,
        AVG(is_late::numeric) AS late_delivery_rate
    FROM seller_order_metrics
    GROUP BY seller_id
)
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    ROUND(m.total_gmv::numeric, 2) AS gmv,
    m.total_orders,
    ROUND(m.avg_review_score::numeric, 2) AS avg_score,
    ROUND(m.avg_freight_value::numeric, 2) AS avg_freight,
    ROUND(m.late_delivery_rate::numeric * 100, 2) AS late_rate_pct,
    CASE
        WHEN m.total_gmv > 5000 AND m.avg_review_score >= 4.5 AND m.late_delivery_rate < 0.1
            THEN 'Top Tier Seller'
        WHEN m.avg_review_score < 3.0 OR m.late_delivery_rate > 0.2
            THEN 'High Risk Seller'
        ELSE 'Ordinary Seller'
    END AS seller_category
FROM olist_sellers s
JOIN seller_metrics m
    ON s.seller_id = m.seller_id
ORDER BY m.total_gmv DESC;


-- -----------------------------
-- 8) SELLER PORTFOLIO SUMMARY
-- -----------------------------
CREATE OR REPLACE VIEW vw_seller_portfolio AS
WITH seller_order_metrics AS (
    SELECT
        i.seller_id,
        i.order_id,
        SUM(i.price) AS seller_order_gmv,
        AVG(r.review_score) AS review_score,
        MAX(CASE WHEN o.is_late = TRUE THEN 1 ELSE 0 END) AS is_late
    FROM olist_order_items i
    JOIN olist_orders o
        ON i.order_id = o.order_id
    LEFT JOIN olist_order_reviews r
        ON i.order_id = r.order_id
    GROUP BY i.seller_id, i.order_id
),
seller_metrics AS (
    SELECT
        seller_id,
        SUM(seller_order_gmv) AS total_gmv,
        AVG(review_score) AS avg_score,
        AVG(is_late::numeric) AS late_rate
    FROM seller_order_metrics
    GROUP BY seller_id
),
categorized_sellers AS (
    SELECT
        CASE
            WHEN total_gmv > 5000 AND avg_score >= 4.5 AND late_rate < 0.1
                THEN 'Top Tier Seller (High GMV, High Score, Low Delay)'
            WHEN avg_score < 3.0 OR late_rate > 0.2
                THEN 'High Risk Seller (Low Score or High Delay Risk)'
            ELSE 'Ordinary Seller'
        END AS category,
        total_gmv
    FROM seller_metrics
)
SELECT
    category,
    COUNT(*) AS number_of_sellers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS proportion_of_sellers_pct,
    ROUND(SUM(total_gmv)::numeric, 2) AS contribution_to_total_gmv,
    ROUND(SUM(total_gmv) * 100.0 / SUM(SUM(total_gmv)) OVER (), 2) AS gmv_proportion_pct
FROM categorized_sellers
GROUP BY category
ORDER BY number_of_sellers DESC;


-- -----------------------------
-- 9) CUSTOMER PORTFOLIO SUMMARY
-- -----------------------------
CREATE OR REPLACE VIEW vw_customer_portfolio AS
WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(i.price) AS total_spent,
        MAX(o.order_purchase_timestamp) AS last_purchase_date
    FROM olist_customers c
    JOIN olist_orders o
        ON c.customer_id = o.customer_id
    JOIN olist_order_items i
        ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
retention_stats AS (
    SELECT
        COUNT(*) AS total_customers,
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
        AVG(total_spent) AS avg_per_customer,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_spent) AS top_5_percentile
    FROM customer_spending
)
SELECT
    total_customers AS total_number_of_customers,
    repeat_customers,
    ROUND((repeat_customers * 100.0 / total_customers)::numeric, 2) AS repeat_rate_pct,
    ROUND(avg_per_customer::numeric, 2) AS avg_customer_value,
    ROUND(top_5_percentile::numeric, 2) AS high_value_threshold_top_5
FROM retention_stats;


-- -----------------------------
-- 10) CUSTOMER RFM DETAIL
-- Optional but useful for drill-through / table
-- -----------------------------
CREATE OR REPLACE VIEW vw_customer_rfm_detail AS
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        DATE_PART(
            'day',
            (SELECT MAX(order_purchase_timestamp) FROM olist_orders) - MAX(o.order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(i.price) AS monetary
    FROM olist_customers c
    JOIN olist_orders o
        ON c.customer_id = o.customer_id
    JOIN olist_order_items i
        ON o.order_id = i.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    recency AS days_since_last_purchase,
    frequency AS purchase_frequency,
    ROUND(monetary::numeric, 2) AS total_spent,
    CASE
        WHEN frequency > 1 AND monetary > 500 AND recency < 90
            THEN 'Core VIP Customer'
        WHEN frequency > 1 AND recency >= 90
            THEN 'Needs Retention - High-Value Customers'
        WHEN frequency = 1 AND monetary > 500
            THEN 'High-Value New Customer'
        ELSE 'Regular Customer'
    END AS customer_level
FROM rfm_base
ORDER BY monetary DESC;