SELECT 
    c.customer_state AS state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.item_total_value)::NUMERIC, 2) AS total_gmv,
    ROUND(AVG(r.review_score)::NUMERIC, 2) AS avg_review_score,
    ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)))::NUMERIC, 2) AS avg_delivery_days,
    ROUND(
        SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)::NUMERIC 
        / COUNT(DISTINCT o.order_id) * 100, 2
    ) || '%' AS late_delivery_rate
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
LEFT JOIN olist_order_items i ON o.order_id = i.order_id
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_orders DESC;

/*
The geographic analysis shows that Olist’s performance was heavily concentrated in a few major states. SP was the dominant market, 
generating 40,501 orders and 5.80M in GMV, followed by RJ and MG. Together, these three states contributed the majority of overall sales, 
showing that business activity was centered in Brazil’s largest markets. At the same time, delivery performance varied significantly across 
regions: SP had the fastest shipping and one of the highest review scores, while states such as RR, AP, and AM had much longer delivery times, 
and AL, MA, and SE had the highest late delivery rates. This suggests that geographic distance and logistics capacity likely 
influenced both fulfillment performance and customer satisfaction.

[
  {
    "state": "SP",
    "total_orders": "40501",
    "total_gmv": "5799283.95",
    "avg_review_score": "4.18",
    "avg_delivery_days": "8.26",
    "late_delivery_rate": "6.63%"
  },
  {
    "state": "RJ",
    "total_orders": "12350",
    "total_gmv": "2063593.64",
    "avg_review_score": "3.87",
    "avg_delivery_days": "14.70",
    "late_delivery_rate": "14.95%"
  },
  {
    "state": "MG",
    "total_orders": "11354",
    "total_gmv": "1826486.53",
    "avg_review_score": "4.12",
    "avg_delivery_days": "11.52",
    "late_delivery_rate": "6.22%"
  },
  {
    "state": "RS",
    "total_orders": "5345",
    "total_gmv": "865877.26",
    "avg_review_score": "4.09",
    "avg_delivery_days": "14.72",
    "late_delivery_rate": "7.97%"
  },
  {
    "state": "PR",
    "total_orders": "4923",
    "total_gmv": "785095.06",
    "avg_review_score": "4.14",
    "avg_delivery_days": "11.49",
    "late_delivery_rate": "5.53%"
  },
  {
    "state": "SC",
    "total_orders": "3546",
    "total_gmv": "597067.83",
    "avg_review_score": "4.05",
    "avg_delivery_days": "14.54",
    "late_delivery_rate": "11.17%"
  },
  {
    "state": "BA",
    "total_orders": "3256",
    "total_gmv": "593408.37",
    "avg_review_score": "3.86",
    "avg_delivery_days": "18.79",
    "late_delivery_rate": "15.60%"
  },
  {
    "state": "DF",
    "total_orders": "2080",
    "total_gmv": "348601.41",
    "avg_review_score": "4.06",
    "avg_delivery_days": "12.53",
    "late_delivery_rate": "8.56%"
  },
  {
    "state": "ES",
    "total_orders": "1995",
    "total_gmv": "318466.51",
    "avg_review_score": "4.02",
    "avg_delivery_days": "15.20",
    "late_delivery_rate": "13.68%"
  },
  {
    "state": "GO",
    "total_orders": "1957",
    "total_gmv": "337665.51",
    "avg_review_score": "4.04",
    "avg_delivery_days": "14.94",
    "late_delivery_rate": "9.25%"
  },
  {
    "state": "PE",
    "total_orders": "1593",
    "total_gmv": "310257.50",
    "avg_review_score": "4.02",
    "avg_delivery_days": "17.76",
    "late_delivery_rate": "11.17%"
  },
  {
    "state": "CE",
    "total_orders": "1279",
    "total_gmv": "267267.58",
    "avg_review_score": "3.87",
    "avg_delivery_days": "20.53",
    "late_delivery_rate": "17.12%"
  },
  {
    "state": "PA",
    "total_orders": "946",
    "total_gmv": "212658.82",
    "avg_review_score": "3.84",
    "avg_delivery_days": "23.31",
    "late_delivery_rate": "13.85%"
  },
  {
    "state": "MT",
    "total_orders": "886",
    "total_gmv": "181579.03",
    "avg_review_score": "4.01",
    "avg_delivery_days": "17.50",
    "late_delivery_rate": "7.90%"
  },
  {
    "state": "MA",
    "total_orders": "717",
    "total_gmv": "148141.69",
    "avg_review_score": "3.77",
    "avg_delivery_days": "21.14",
    "late_delivery_rate": "22.73%"
  },
  {
    "state": "MS",
    "total_orders": "701",
    "total_gmv": "136005.96",
    "avg_review_score": "4.07",
    "avg_delivery_days": "15.11",
    "late_delivery_rate": "12.70%"
  },
  {
    "state": "PB",
    "total_orders": "517",
    "total_gmv": "137953.28",
    "avg_review_score": "4.04",
    "avg_delivery_days": "20.10",
    "late_delivery_rate": "12.77%"
  },
  {
    "state": "PI",
    "total_orders": "476",
    "total_gmv": "105259.41",
    "avg_review_score": "3.96",
    "avg_delivery_days": "18.93",
    "late_delivery_rate": "17.02%"
  },
  {
    "state": "RN",
    "total_orders": "474",
    "total_gmv": "100833.26",
    "avg_review_score": "4.11",
    "avg_delivery_days": "18.86",
    "late_delivery_rate": "11.39%"
  },
  {
    "state": "AL",
    "total_orders": "397",
    "total_gmv": "94475.18",
    "avg_review_score": "3.82",
    "avg_delivery_days": "23.98",
    "late_delivery_rate": "26.20%"
  },
  {
    "state": "SE",
    "total_orders": "335",
    "total_gmv": "70289.13",
    "avg_review_score": "3.90",
    "avg_delivery_days": "20.98",
    "late_delivery_rate": "18.21%"
  },
  {
    "state": "TO",
    "total_orders": "274",
    "total_gmv": "60007.37",
    "avg_review_score": "4.16",
    "avg_delivery_days": "17.00",
    "late_delivery_rate": "13.87%"
  },
  {
    "state": "RO",
    "total_orders": "243",
    "total_gmv": "56966.00",
    "avg_review_score": "4.07",
    "avg_delivery_days": "19.28",
    "late_delivery_rate": "4.53%"
  },
  {
    "state": "AM",
    "total_orders": "145",
    "total_gmv": "27668.61",
    "avg_review_score": "4.09",
    "avg_delivery_days": "25.93",
    "late_delivery_rate": "4.83%"
  },
  {
    "state": "AC",
    "total_orders": "80",
    "total_gmv": "19575.33",
    "avg_review_score": "4.13",
    "avg_delivery_days": "20.33",
    "late_delivery_rate": "3.75%"
  },
  {
    "state": "AP",
    "total_orders": "67",
    "total_gmv": "16141.81",
    "avg_review_score": "4.26",
    "avg_delivery_days": "27.75",
    "late_delivery_rate": "5.97%"
  },
  {
    "state": "RR",
    "total_orders": "41",
    "total_gmv": "9039.52",
    "avg_review_score": "3.89",
    "avg_delivery_days": "27.83",
    "late_delivery_rate": "12.20%"
  }
]
*/