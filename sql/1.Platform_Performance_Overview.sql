
----Platform Performance Overview----

WITH order_summary as (
SELECT 
    o.order_id,
    o.order_status,
    SUM(i.item_total_value) as order_gmv
FROM olist_orders o
LEFT JOIN olist_order_items i ON o.order_id = i.order_id
GROUP BY o.order_id, o.order_status
)

SELECT 
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) as delivered_orders,
    ROUND(SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END)
    ::NUMERIC/COUNT(order_id) * 100, 2) || '%' as delivery_rate,
    ROUND(SUM(order_gmv)::NUMERIC, 2) as total_gmv,
    ROUND(AVG(order_gmv)::NUMERIC, 2) as aov
FROM order_summary

/*

The results show that Olist processed nearly 99.4K orders, with 97.02% delivered successfully, 
indicating a highly reliable fulfillment process. The platform generated 15.84M in GMV, while the 
average order value was 160.58, suggesting steady customer spending per transaction. Together, these 
metrics show that the business performed well in both revenue generation and order completion.




[

  {

    "total_orders": "99441",

    "delivered_orders": "96478",

    "delivery_rate": "97.02%",

    "total_gmv": "15843553.24",

    "aov": "160.58"

  }

]

*/

-------------------------------------------------------------------------

SELECT
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') as month,
    COUNT(DISTINCT o.order_id) as monthly_orders,
    ROUND(SUM(item_total_value)::NUMERIC, 2) as monthly_gmv
FROM olist_orders o
JOIN olist_order_items i ON o.order_id = i.order_id
GROUP BY MONTH
ORDER BY MONTH

/*
The monthly trend analysis shows that Olist grew significantly over the observed period. Monthly orders 
increased from 789 in January 2017 to 7,451 in November 2017, while monthly GMV rose from 137.2K to 1.18M 
over the same period. The strong peak in November 2017 suggests seasonal demand, likely related to major 
promotional or holiday shopping periods. In 2018, both order volume and GMV remained at consistently high levels, 
indicating that the business had moved from rapid expansion into a more stable stage of growth. Partial-month 
observations at the beginning and end of the dataset should be interpreted cautiously.

[
  {
    "month": "2016-09",
    "monthly_orders": "3",
    "monthly_gmv": "354.75"
  },
  {
    "month": "2016-10",
    "monthly_orders": "308",
    "monthly_gmv": "56808.84"
  },
  {
    "month": "2016-12",
    "monthly_orders": "1",
    "monthly_gmv": "19.62"
  },
  {
    "month": "2017-01",
    "monthly_orders": "789",
    "monthly_gmv": "137188.49"
  },
  {
    "month": "2017-02",
    "monthly_orders": "1733",
    "monthly_gmv": "286280.62"
  },
  {
    "month": "2017-03",
    "monthly_orders": "2641",
    "monthly_gmv": "432048.59"
  },
  {
    "month": "2017-04",
    "monthly_orders": "2391",
    "monthly_gmv": "412422.24"
  },
  {
    "month": "2017-05",
    "monthly_orders": "3660",
    "monthly_gmv": "586190.95"
  },
  {
    "month": "2017-06",
    "monthly_orders": "3217",
    "monthly_gmv": "502963.04"
  },
  {
    "month": "2017-07",
    "monthly_orders": "3969",
    "monthly_gmv": "584971.62"
  },
  {
    "month": "2017-08",
    "monthly_orders": "4293",
    "monthly_gmv": "668204.60"
  },
  {
    "month": "2017-09",
    "monthly_orders": "4243",
    "monthly_gmv": "720398.91"
  },
  {
    "month": "2017-10",
    "monthly_orders": "4568",
    "monthly_gmv": "769312.37"
  },
  {
    "month": "2017-11",
    "monthly_orders": "7451",
    "monthly_gmv": "1179143.77"
  },
  {
    "month": "2017-12",
    "monthly_orders": "5624",
    "monthly_gmv": "863547.23"
  },
  {
    "month": "2018-01",
    "monthly_orders": "7220",
    "monthly_gmv": "1107301.89"
  },
  {
    "month": "2018-02",
    "monthly_orders": "6694",
    "monthly_gmv": "986908.96"
  },
  {
    "month": "2018-03",
    "monthly_orders": "7188",
    "monthly_gmv": "1155126.82"
  },
  {
    "month": "2018-04",
    "monthly_orders": "6934",
    "monthly_gmv": "1159698.04"
  },
  {
    "month": "2018-05",
    "monthly_orders": "6853",
    "monthly_gmv": "1149781.82"
  },
  {
    "month": "2018-06",
    "monthly_orders": "6160",
    "monthly_gmv": "1022677.11"
  },
  {
    "month": "2018-07",
    "monthly_orders": "6273",
    "monthly_gmv": "1058728.03"
  },
  {
    "month": "2018-08",
    "monthly_orders": "6452",
    "monthly_gmv": "1003308.47"
  },
  {
    "month": "2018-09",
    "monthly_orders": "1",
    "monthly_gmv": "166.46"
  }
]
*/