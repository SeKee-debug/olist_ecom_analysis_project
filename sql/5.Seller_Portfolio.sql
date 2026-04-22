
WITH sellers_metrics as (
    SELECT 
        i.seller_id,
        SUM(i.price) AS total_gmv,
        COUNT(DISTINCT i.order_id) AS total_orders,
        AVG(i.freight_value) AS avg_freight_value,
        AVG(r.review_score) AS avg_review_score,
        CAST(SUM(CASE WHEN o.is_late = TRUE THEN 1 ELSE 0 END) AS FLOAT) / 
        COUNT(o.order_id) AS late_delivery_rate
    FROM olist_order_items i
    JOIN olist_orders o ON i.order_id = o.order_id
    LEFT JOIN olist_order_reviews r ON i.order_id = r.order_id
    GROUP BY i.seller_id
    )

SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    ROUND(m.total_gmv::numeric, 2) AS gmv,
    m.total_orders,
    ROUND(m.avg_review_score::numeric, 2) AS avg_score,
    ROUND(m.avg_freight_value::numeric, 2) AS avg_freight,
    ROUND((m.late_delivery_rate * 100)::numeric, 2) || '%' AS late_rate,
    CASE 
        WHEN m.total_gmv > 5000 AND m.avg_review_score >= 4.5 THEN 'Top Tier Seller'
        WHEN m.avg_review_score < 3.0 OR m.late_delivery_rate > 0.2 THEN 'High Risk Seller'
        ELSE 'Ordinary seller'
    END AS seller_category
FROM 
    olist_sellers s
JOIN 
    sellers_metrics m ON s.seller_id = m.seller_id
ORDER BY 
    m.total_gmv DESC;

---------------------------------------

WITH seller_metrics AS (
    SELECT 
        i.seller_id,
        SUM(i.price) AS total_gmv,
        AVG(r.review_score) AS avg_score,
        CAST(SUM(CASE WHEN o.is_late = TRUE THEN 1 ELSE 0 END) AS FLOAT) / COUNT(o.order_id) AS late_rate
    FROM olist_order_items i
    JOIN olist_orders o ON i.order_id = o.order_id
    LEFT JOIN olist_order_reviews r ON i.order_id = r.order_id
    GROUP BY i.seller_id
),
categorized_sellers AS (
    SELECT 
        CASE 
            WHEN total_gmv > 5000 AND avg_score >= 4.5 AND late_rate < 0.1 THEN 'Top Tier Seller (High GMV, High Score, Low Delay)'
            WHEN avg_score < 3.0 OR late_rate > 0.2 THEN 'High Risk Seller (Low Score or High Delay Risk)'
            ELSE 'Ordinary Seller'
        END AS category,
        total_gmv
    FROM seller_metrics
)

SELECT 
    category,
    COUNT(*) AS Number_of_Sellers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) || '%' AS Proportion_of_sellers,
    ROUND(SUM(total_gmv)::numeric, 2) AS Contribution_to_total_GMV,
    ROUND(SUM(total_gmv) * 100.0 / SUM(SUM(total_gmv)) OVER(), 2) || '%' AS GMV_Proportion
FROM categorized_sellers
GROUP BY category
ORDER BY Number_of_Sellers DESC;

/*
This seller portfolio analysis shows that Olist’s seller base was dominated by Ordinary Sellers, who made up 
80.32% of all sellers and contributed 89.91% of total GMV. This means that most of the platform’s revenue came 
from the broad middle of the seller base rather than from a small group of exceptional sellers. In contrast, 
Top Tier Sellers accounted for only 1.52% of sellers, but still generated 3.77% of GMV, showing that high-performing 
ellers were few in number but relatively productive. Meanwhile, High Risk Sellers represented 18.16% of sellers 
but contributed just 6.32% of GMV, suggesting that this group added limited sales value while also carrying greater 
operational or customer satisfaction risk. Overall, the results suggest that Olist relied mainly on its ordinary seller 
base, while top-tier sellers offered strong efficiency and high-risk sellers may require closer monitoring or improvement.

[
  {
    "category": "Ordinary Seller",
    "number_of_sellers": "2486",
    "proportion_of_sellers": "80.32%",
    "contribution_to_total_gmv": "12274420.14",
    "gmv_proportion": "89.91%"
  },
  {
    "category": "High Risk Seller (Low Score or High Delay Risk)",
    "number_of_sellers": "562",
    "proportion_of_sellers": "18.16%",
    "contribution_to_total_gmv": "862513.09",
    "gmv_proportion": "6.32%"
  },
  {
    "category": "Top Tier Seller (High GMV, High Score, Low Delay)",
    "number_of_sellers": "47",
    "proportion_of_sellers": "1.52%",
    "contribution_to_total_gmv": "514990.24",
    "gmv_proportion": "3.77%"
  }
]

*/