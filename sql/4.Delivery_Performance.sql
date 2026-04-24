
SELECT 
    CASE WHEN is_late = TRUE THEN 'Late' ELSE 'On-time' END AS delivery_status,
    COUNT(o.order_id) AS total_orders,
    -- 平均评分
    ROUND(AVG(r.review_score)::NUMERIC, 2) AS avg_review_score,
    -- 负评比例 (1-2分)
    ROUND(
        SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END)::NUMERIC 
        / COUNT(o.order_id) * 100, 2
    ) || '%' AS negative_review_rate
FROM olist_orders o
JOIN olist_order_reviews r ON o.order_id = r.order_id
GROUP BY delivery_status;

/*
This analysis shows a strong negative relationship between late delivery and customer satisfaction. 
Out of 99,224 orders, 7,701 were delivered late, or about 7.8% of total orders. However, these late 
orders received a much lower average review score of 2.57, compared with 4.21 for on-time orders. The 
share of negative reviews was also dramatically higher for late deliveries: 54.02% of late orders received 
negative reviews, versus only 11.38% for on-time orders. This suggests that delivery delays were strongly 
associated with a worse customer experience and significantly higher dissatisfaction.

  [
  {
    "delivery_status": "Late",
    "total_orders": "7701",
    "avg_review_score": "2.57",
    "negative_review_rate": "54.02%"
  },
  {
    "delivery_status": "On-time",
    "total_orders": "91523",
    "avg_review_score": "4.21",
    "negative_review_rate": "11.38%"
  }
]


*/



SELECT 
    CASE 
        WHEN delivery_days <= 7 THEN '0-7 Days'
        WHEN delivery_days <= 14 THEN '8-14 Days'
        WHEN delivery_days <= 21 THEN '15-21 Days'
        ELSE 'Over 21 Days'
    END AS delivery_window,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(r.review_score)::NUMERIC, 2) AS avg_review_score
FROM olist_orders o
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE delivery_days IS NOT NULL
GROUP BY delivery_window
ORDER BY MIN(delivery_days);



/*
The binned results reveal a strong association between longer delivery times and lower customer ratings. 
Review scores remained relatively high for orders delivered within the first three weeks, declining 
gradually from 4.41 in the 0–7 day group to 4.10 in the 15–21 day group. In contrast, orders taking more 
than 21 days received a much lower average review score of 3.01, indicating a clear deterioration in customer 
experience when delivery becomes excessively slow. Overall, the results suggest that delivery speed is an 
important driver of satisfaction, and that delays beyond three weeks may significantly harm customer perception.

[
  {
    "delivery_window": "0-7 Days",
    "total_orders": "33685",
    "avg_review_score": "4.41"
  },
  {
    "delivery_window": "8-14 Days",
    "total_orders": "36396",
    "avg_review_score": "4.29"
  },
  {
    "delivery_window": "15-21 Days",
    "total_orders": "15381",
    "avg_review_score": "4.10"
  },
  {
    "delivery_window": "Over 21 Days",
    "total_orders": "10897",
    "avg_review_score": "3.01"
  }
]

*/