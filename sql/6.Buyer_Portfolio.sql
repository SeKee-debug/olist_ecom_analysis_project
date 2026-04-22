WITH customer_spending AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(i.price) AS total_spent,
        MAX(o.order_purchase_timestamp) AS last_purchase_date
    FROM olist_customers c
    JOIN olist_orders o ON c.customer_id = o.customer_id
    JOIN olist_order_items i ON o.order_id = i.order_id
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
    repeat_customers AS repeat_customers,
    ROUND((repeat_customers * 100.0 / total_customers)::numeric, 2) || '%' AS repeat_rate,
    ROUND(avg_per_customer::numeric, 2) AS avg_customer_value,
    ROUND(top_5_percentile::numeric, 2) AS high_value_threshold_top_5
FROM retention_stats;
/*
The customer portfolio analysis shows that Olist had a large customer base, but a low repeat 
purchase rate of 3.00%, indicating that most customers only bought once. This suggests that 
the business relied more on customer acquisition than on repeat buying. At the same time, the 
average customer value was 141.62, while the top 5% high-value customer threshold was 419.81, 
showing that a small group of customers contributed substantially more value than the average buyer. 
Overall, the results point to an opportunity to improve customer retention and better engage high-value customers.

[
  {
    "total_number_of_customers": "93358",
    "repeat_customers": "2801",
    "repeat_rate": "3.00%",
    "avg_customer_value": "141.62",
    "high_value_threshold_top_5": "419.81"
  }
]

*/


---------------------------------------------

WITH rfm_base AS (
    SELECT 
        c.customer_unique_id,
        DATE_PART('day', (SELECT MAX(order_purchase_timestamp) FROM olist_orders) - MAX(o.order_purchase_timestamp)) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(i.price) AS monetary
    FROM olist_customers c
    JOIN olist_orders o ON c.customer_id = o.customer_id
    JOIN olist_order_items i ON o.order_id = i.order_id
    GROUP BY c.customer_unique_id
)
SELECT 
    customer_unique_id,
    recency AS days_since_last_purchase,
    frequency AS purchase_frequency,
    ROUND(monetary::numeric, 2) AS total_spent,
    CASE 
        WHEN frequency > 1 AND monetary > 500 AND recency < 90 THEN 'Core VIP Customer'
        WHEN frequency > 1 AND recency >= 90 THEN 'Needs Retention - High-Value Customers'
        WHEN frequency = 1 AND monetary > 500 THEN 'High-Value New Customer'
        ELSE 'Regular Customer'
    END AS customer_level
FROM rfm_base
ORDER BY monetary DESC
LIMIT 20;


/*
This result highlights the difference between high-spending and loyal customers. Many of the top 
customers were classified as High-Value New Customers, meaning they contributed large amounts of 
revenue but purchased only once. In contrast, only a small number appeared to be true repeat high
-value customers, such as the Core VIP Customer segment. The presence of Needs Retention customer
also suggests that some previously valuable buyers had become inactive. Overall, the pattern shows
 that Olist was able to attract big spenders, but may have had difficulty retaining them over time.

[
  {
    "customer_unique_id": "0a0a92112bd4c708ca5fde585afaa872",
    "days_since_last_purchase": 383,
    "purchase_frequency": "1",
    "total_spent": "13440.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "da122df9eeddfedc1dc1f5349a1a690c",
    "days_since_last_purchase": 564,
    "purchase_frequency": "2",
    "total_spent": "7388.00",
    "customer_level": "Needs Retention - High-Value Customers"
  },
  {
    "customer_unique_id": "763c8b1c9c68a0229c42c9fc6f662b93",
    "days_since_last_purchase": 94,
    "purchase_frequency": "1",
    "total_spent": "7160.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "dc4802a71eae9be1dd28f5d788ceb526",
    "days_since_last_purchase": 611,
    "purchase_frequency": "1",
    "total_spent": "6735.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "459bef486812aa25204be022145caa62",
    "days_since_last_purchase": 83,
    "purchase_frequency": "1",
    "total_spent": "6729.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "ff4159b92c40ebe40454e3e6a7c35ed6",
    "days_since_last_purchase": 510,
    "purchase_frequency": "1",
    "total_spent": "6499.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "4007669dec559734d6f53e029e360987",
    "days_since_last_purchase": 327,
    "purchase_frequency": "1",
    "total_spent": "5934.60",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "eebb5dda148d3893cdaf5b5ca3040ccb",
    "days_since_last_purchase": 546,
    "purchase_frequency": "1",
    "total_spent": "4690.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "5d0a2980b292d049061542014e8960bf",
    "days_since_last_purchase": 97,
    "purchase_frequency": "1",
    "total_spent": "4599.90",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "48e1ac109decbb87765a3eade6854098",
    "days_since_last_purchase": 117,
    "purchase_frequency": "1",
    "total_spent": "4590.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "a229eba70ec1c2abef51f04987deb7a5",
    "days_since_last_purchase": 138,
    "purchase_frequency": "1",
    "total_spent": "4400.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "edde2314c6c30e864a128ac95d6b2112",
    "days_since_last_purchase": 74,
    "purchase_frequency": "1",
    "total_spent": "4399.87",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "fa562ef24d41361e476e748681810e1e",
    "days_since_last_purchase": 202,
    "purchase_frequency": "1",
    "total_spent": "4099.99",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "c8460e4251689ba205045f3ea17884a1",
    "days_since_last_purchase": 70,
    "purchase_frequency": "4",
    "total_spent": "4080.00",
    "customer_level": "Core VIP Customer"
  },
  {
    "customer_unique_id": "ca27f3dac28fb1063faddd424c9d95fa",
    "days_since_last_purchase": 80,
    "purchase_frequency": "1",
    "total_spent": "4059.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "055ec572ac7f3c7bdd04a183830ebe59",
    "days_since_last_purchase": 455,
    "purchase_frequency": "2",
    "total_spent": "3999.98",
    "customer_level": "Needs Retention - High-Value Customers"
  },
  {
    "customer_unique_id": "011875f0176909c5cf0b14a9138bb691",
    "days_since_last_purchase": 577,
    "purchase_frequency": "1",
    "total_spent": "3999.90",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "edf81e1f3070b9dac83ec83dacdbb9bc",
    "days_since_last_purchase": 546,
    "purchase_frequency": "1",
    "total_spent": "3999.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "5e713be0853d8986528d7869a0811d2b",
    "days_since_last_purchase": 619,
    "purchase_frequency": "1",
    "total_spent": "3980.00",
    "customer_level": "High-Value New Customer"
  },
  {
    "customer_unique_id": "f0767ae738c3d90e7b737d7b8b8bb4d1",
    "days_since_last_purchase": 156,
    "purchase_frequency": "1",
    "total_spent": "3930.00",
    "customer_level": "High-Value New Customer"
  }
]

*/