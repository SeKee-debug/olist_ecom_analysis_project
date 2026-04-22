SELECT 
    p.product_category_name_english as category,
    COUNT(DISTINCT i.order_id) as total_orders,
    ROUND(SUM(i.item_total_value)::NUMERIC, 2) as total_gmv,
    ROUND(AVG(r.review_score)::NUMERIC, 2) as avg_review_score,
    ROUND(AVG(i.freight_value)::NUMERIC, 2) as avg_freight,
    ROUND(AVG(i.freight_value / i.item_total_value)::NUMERIC * 100, 2) || '%' as avg_freight_ratio
FROM olist_order_items i
JOIN olist_products p ON i.product_id = p.product_id
LEFT JOIN olist_order_reviews r ON i.order_id = r.order_id
GROUP BY category
ORDER BY total_gmv DESC;

------------------------------------

/*
The category-level analysis shows that Olist’s business was driven by a few major product groups. 
Bed bath table led in order volume, while health beauty generated the highest GMV, followed by watches 
gifts and sports leisure. This indicates that both essential household goods and personal lifestyle products 
were key revenue drivers for the platform. The results also highlight differences in category efficiency: watches 
gifts stood out as a high-value category with a relatively low freight ratio, while telephony and electronics 
had much higher shipping-cost burdens. In terms of customer satisfaction, health beauty and sports leisure 
performed well, while office furniture had the lowest review score among larger categories, suggesting that 
more complex products may create greater delivery or service issues.

[
  {
    "category": "health_beauty",
    "total_orders": "8836",
    "total_gmv": "1446622.08",
    "avg_review_score": "4.14",
    "avg_freight": "18.86",
    "avg_freight_ratio": "19.93%"
  },
  {
    "category": "watches_gifts",
    "total_orders": "5624",
    "total_gmv": "1306761.40",
    "avg_review_score": "4.02",
    "avg_freight": "16.78",
    "avg_freight_ratio": "13.14%"
  },
  {
    "category": "bed_bath_table",
    "total_orders": "9417",
    "total_gmv": "1258189.51",
    "avg_review_score": "3.90",
    "avg_freight": "18.39",
    "avg_freight_ratio": "20.30%"
  },
  {
    "category": "sports_leisure",
    "total_orders": "7720",
    "total_gmv": "1163329.98",
    "avg_review_score": "4.11",
    "avg_freight": "19.50",
    "avg_freight_ratio": "20.35%"
  },
  {
    "category": "computers_accessories",
    "total_orders": "6689",
    "total_gmv": "1068070.48",
    "avg_review_score": "3.93",
    "avg_freight": "18.80",
    "avg_freight_ratio": "20.24%"
  },
  {
    "category": "furniture_decor",
    "total_orders": "6449",
    "total_gmv": "910683.05",
    "avg_review_score": "3.90",
    "avg_freight": "20.72",
    "avg_freight_ratio": "23.28%"
  },
  {
    "category": "housewares",
    "total_orders": "5884",
    "total_gmv": "781170.03",
    "avg_review_score": "4.06",
    "avg_freight": "20.98",
    "avg_freight_ratio": "25.19%"
  },
  {
    "category": "cool_stuff",
    "total_orders": "3632",
    "total_gmv": "721492.90",
    "avg_review_score": "4.15",
    "avg_freight": "22.13",
    "avg_freight_ratio": "16.29%"
  },
  {
    "category": "auto",
    "total_orders": "3897",
    "total_gmv": "687374.19",
    "avg_review_score": "4.07",
    "avg_freight": "21.85",
    "avg_freight_ratio": "21.51%"
  },
  {
    "category": "garden_tools",
    "total_orders": "3518",
    "total_gmv": "585646.54",
    "avg_review_score": "4.04",
    "avg_freight": "22.75",
    "avg_freight_ratio": "23.02%"
  },
  {
    "category": "toys",
    "total_orders": "3886",
    "total_gmv": "562310.57",
    "avg_review_score": "4.16",
    "avg_freight": "18.80",
    "avg_freight_ratio": "18.90%"
  },
  {
    "category": "baby",
    "total_orders": "2885",
    "total_gmv": "480647.26",
    "avg_review_score": "4.01",
    "avg_freight": "22.30",
    "avg_freight_ratio": "20.59%"
  },
  {
    "category": "perfumery",
    "total_orders": "3162",
    "total_gmv": "454664.54",
    "avg_review_score": "4.16",
    "avg_freight": "15.85",
    "avg_freight_ratio": "18.34%"
  },
  {
    "category": "telephony",
    "total_orders": "4199",
    "total_gmv": "395190.98",
    "avg_review_score": "3.95",
    "avg_freight": "15.68",
    "avg_freight_ratio": "30.02%"
  },
  {
    "category": "office_furniture",
    "total_orders": "1273",
    "total_gmv": "344082.76",
    "avg_review_score": "3.49",
    "avg_freight": "40.48",
    "avg_freight_ratio": "20.49%"
  },
  {
    "category": "stationery",
    "total_orders": "2311",
    "total_gmv": "278224.15",
    "avg_review_score": "4.19",
    "avg_freight": "18.58",
    "avg_freight_ratio": "21.60%"
  },
  {
    "category": "pet_shop",
    "total_orders": "1710",
    "total_gmv": "254190.79",
    "avg_review_score": "4.19",
    "avg_freight": "20.32",
    "avg_freight_ratio": "20.67%"
  },
  {
    "category": "computers",
    "total_orders": "181",
    "total_gmv": "232799.43",
    "avg_review_score": "4.18",
    "avg_freight": "48.45",
    "avg_freight_ratio": "5.17%"
  },
  {
    "category": "unknown",
    "total_orders": "1473",
    "total_gmv": "214588.51",
    "avg_review_score": "3.83",
    "avg_freight": "17.60",
    "avg_freight_ratio": "21.26%"
  },
  {
    "category": "musical_instruments",
    "total_orders": "628",
    "total_gmv": "210173.23",
    "avg_review_score": "4.15",
    "avg_freight": "27.39",
    "avg_freight_ratio": "17.46%"
  },
  {
    "category": "small_appliances",
    "total_orders": "630",
    "total_gmv": "207736.19",
    "avg_review_score": "4.15",
    "avg_freight": "23.67",
    "avg_freight_ratio": "17.75%"
  },
  {
    "category": "electronics",
    "total_orders": "2550",
    "total_gmv": "206989.23",
    "avg_review_score": "4.04",
    "avg_freight": "16.84",
    "avg_freight_ratio": "35.80%"
  },
  {
    "category": "fashion_bags_accessories",
    "total_orders": "1864",
    "total_gmv": "185436.22",
    "avg_review_score": "4.14",
    "avg_freight": "15.50",
    "avg_freight_ratio": "23.09%"
  },
  {
    "category": "consoles_games",
    "total_orders": "1062",
    "total_gmv": "177844.54",
    "avg_review_score": "4.02",
    "avg_freight": "17.44",
    "avg_freight_ratio": "23.18%"
  },
  {
    "category": "luggage_accessories",
    "total_orders": "1034",
    "total_gmv": "170875.21",
    "avg_review_score": "4.32",
    "avg_freight": "27.88",
    "avg_freight_ratio": "19.56%"
  },
  {
    "category": "construction_tools_construction",
    "total_orders": "748",
    "total_gmv": "166199.44",
    "avg_review_score": "4.05",
    "avg_freight": "22.22",
    "avg_freight_ratio": "20.34%"
  },
  {
    "category": "home_appliances_2",
    "total_orders": "234",
    "total_gmv": "124220.38",
    "avg_review_score": "4.14",
    "avg_freight": "44.31",
    "avg_freight_ratio": "14.84%"
  },
  {
    "category": "home_appliances",
    "total_orders": "764",
    "total_gmv": "98758.41",
    "avg_review_score": "4.17",
    "avg_freight": "19.24",
    "avg_freight_ratio": "25.61%"
  },
  {
    "category": "home_construction",
    "total_orders": "490",
    "total_gmv": "97052.07",
    "avg_review_score": "3.94",
    "avg_freight": "22.88",
    "avg_freight_ratio": "18.93%"
  },
  {
    "category": "furniture_living_room",
    "total_orders": "422",
    "total_gmv": "87523.96",
    "avg_review_score": "3.90",
    "avg_freight": "35.69",
    "avg_freight_ratio": "23.31%"
  },
  {
    "category": "agro_industry_and_commerce",
    "total_orders": "182",
    "total_gmv": "78374.07",
    "avg_review_score": "4.00",
    "avg_freight": "27.56",
    "avg_freight_ratio": "17.48%"
  },
  {
    "category": "home_confort",
    "total_orders": "397",
    "total_gmv": "67380.21",
    "avg_review_score": "3.83",
    "avg_freight": "19.57",
    "avg_freight_ratio": "15.98%"
  },
  {
    "category": "fixed_telephony",
    "total_orders": "217",
    "total_gmv": "64281.60",
    "avg_review_score": "3.68",
    "avg_freight": "17.58",
    "avg_freight_ratio": "23.04%"
  },
  {
    "category": "air_conditioning",
    "total_orders": "253",
    "total_gmv": "61774.19",
    "avg_review_score": "3.97",
    "avg_freight": "22.72",
    "avg_freight_ratio": "15.87%"
  },
  {
    "category": "kitchen_dining_laundry_garden_furniture",
    "total_orders": "248",
    "total_gmv": "58542.86",
    "avg_review_score": "3.96",
    "avg_freight": "42.86",
    "avg_freight_ratio": "24.35%"
  },
  {
    "category": "audio",
    "total_orders": "350",
    "total_gmv": "56462.94",
    "avg_review_score": "3.83",
    "avg_freight": "15.68",
    "avg_freight_ratio": "20.79%"
  },
  {
    "category": "books_general_interest",
    "total_orders": "512",
    "total_gmv": "56052.40",
    "avg_review_score": "4.45",
    "avg_freight": "16.63",
    "avg_freight_ratio": "23.77%"
  },
  {
    "category": "small_appliances_home_oven_and_coffee",
    "total_orders": "75",
    "total_gmv": "50193.57",
    "avg_review_score": "4.30",
    "avg_freight": "36.16",
    "avg_freight_ratio": "12.21%"
  },
  {
    "category": "construction_tools_lights",
    "total_orders": "244",
    "total_gmv": "48918.38",
    "avg_review_score": "4.05",
    "avg_freight": "24.95",
    "avg_freight_ratio": "19.02%"
  },
  {
    "category": "industry_commerce_and_business",
    "total_orders": "235",
    "total_gmv": "47651.31",
    "avg_review_score": "4.10",
    "avg_freight": "29.39",
    "avg_freight_ratio": "20.63%"
  },
  {
    "category": "construction_tools_safety",
    "total_orders": "167",
    "total_gmv": "44463.62",
    "avg_review_score": "3.84",
    "avg_freight": "20.20",
    "avg_freight_ratio": "16.48%"
  },
  {
    "category": "food",
    "total_orders": "450",
    "total_gmv": "36664.44",
    "avg_review_score": "4.22",
    "avg_freight": "14.26",
    "avg_freight_ratio": "23.81%"
  },
  {
    "category": "market_place",
    "total_orders": "280",
    "total_gmv": "33834.53",
    "avg_review_score": "4.02",
    "avg_freight": "17.54",
    "avg_freight_ratio": "22.32%"
  },
  {
    "category": "costruction_tools_garden",
    "total_orders": "194",
    "total_gmv": "31105.47",
    "avg_review_score": "4.05",
    "avg_freight": "22.23",
    "avg_freight_ratio": "26.81%"
  },
  {
    "category": "fashion_shoes",
    "total_orders": "240",
    "total_gmv": "28733.87",
    "avg_review_score": "4.23",
    "avg_freight": "18.74",
    "avg_freight_ratio": "21.28%"
  },
  {
    "category": "drinks",
    "total_orders": "297",
    "total_gmv": "28294.07",
    "avg_review_score": "4.05",
    "avg_freight": "15.11",
    "avg_freight_ratio": "27.03%"
  },
  {
    "category": "art",
    "total_orders": "202",
    "total_gmv": "28247.81",
    "avg_review_score": "3.94",
    "avg_freight": "19.35",
    "avg_freight_ratio": "20.50%"
  },
  {
    "category": "signaling_and_security",
    "total_orders": "140",
    "total_gmv": "28017.05",
    "avg_review_score": "4.09",
    "avg_freight": "32.70",
    "avg_freight_ratio": "28.50%"
  },
  {
    "category": "furniture_bedroom",
    "total_orders": "95",
    "total_gmv": "24973.50",
    "avg_review_score": "4.12",
    "avg_freight": "42.68",
    "avg_freight_ratio": "22.62%"
  },
  {
    "category": "books_technical",
    "total_orders": "260",
    "total_gmv": "23456.53",
    "avg_review_score": "4.37",
    "avg_freight": "16.01",
    "avg_freight_ratio": "23.67%"
  },
  {
    "category": "food_drink",
    "total_orders": "227",
    "total_gmv": "19826.80",
    "avg_review_score": "4.32",
    "avg_freight": "16.27",
    "avg_freight_ratio": "30.39%"
  },
  {
    "category": "costruction_tools_tools",
    "total_orders": "97",
    "total_gmv": "17934.17",
    "avg_review_score": "4.44",
    "avg_freight": "19.71",
    "avg_freight_ratio": "23.40%"
  },
  {
    "category": "fashion_male_clothing",
    "total_orders": "112",
    "total_gmv": "12950.23",
    "avg_review_score": "3.64",
    "avg_freight": "16.31",
    "avg_freight_ratio": "19.94%"
  },
  {
    "category": "christmas_supplies",
    "total_orders": "128",
    "total_gmv": "12030.12",
    "avg_review_score": "4.02",
    "avg_freight": "21.11",
    "avg_freight_ratio": "33.80%"
  },
  {
    "category": "fashion_underwear_beach",
    "total_orders": "121",
    "total_gmv": "11457.74",
    "avg_review_score": "3.98",
    "avg_freight": "14.63",
    "avg_freight_ratio": "24.30%"
  },
  {
    "category": "tablets_printing_image",
    "total_orders": "79",
    "total_gmv": "8754.61",
    "avg_review_score": "4.12",
    "avg_freight": "14.77",
    "avg_freight_ratio": "16.68%"
  },
  {
    "category": "cine_photo",
    "total_orders": "65",
    "total_gmv": "8212.95",
    "avg_review_score": "4.21",
    "avg_freight": "17.31",
    "avg_freight_ratio": "23.22%"
  },
  {
    "category": "dvds_blu_ray",
    "total_orders": "59",
    "total_gmv": "7288.13",
    "avg_review_score": "4.08",
    "avg_freight": "20.14",
    "avg_freight_ratio": "40.37%"
  },
  {
    "category": "music",
    "total_orders": "38",
    "total_gmv": "6724.86",
    "avg_review_score": "4.21",
    "avg_freight": "18.17",
    "avg_freight_ratio": "24.49%"
  },
  {
    "category": "furniture_mattress_and_upholstery",
    "total_orders": "38",
    "total_gmv": "5998.54",
    "avg_review_score": "3.82",
    "avg_freight": "42.91",
    "avg_freight_ratio": "30.48%"
  },
  {
    "category": "books_imported",
    "total_orders": "53",
    "total_gmv": "5409.70",
    "avg_review_score": "4.40",
    "avg_freight": "12.83",
    "avg_freight_ratio": "18.18%"
  },
  {
    "category": "party_supplies",
    "total_orders": "39",
    "total_gmv": "5313.15",
    "avg_review_score": "3.77",
    "avg_freight": "19.26",
    "avg_freight_ratio": "24.22%"
  },
  {
    "category": "fashio_female_clothing",
    "total_orders": "39",
    "total_gmv": "3535.84",
    "avg_review_score": "3.78",
    "avg_freight": "12.93",
    "avg_freight_ratio": "21.47%"
  },
  {
    "category": "fashion_sport",
    "total_orders": "27",
    "total_gmv": "2736.73",
    "avg_review_score": "4.26",
    "avg_freight": "19.10",
    "avg_freight_ratio": "23.14%"
  },
  {
    "category": "la_cuisine",
    "total_orders": "13",
    "total_gmv": "2388.54",
    "avg_review_score": "4.00",
    "avg_freight": "23.83",
    "avg_freight_ratio": "15.19%"
  },
  {
    "category": "arts_and_craftmanship",
    "total_orders": "23",
    "total_gmv": "2184.14",
    "avg_review_score": "4.13",
    "avg_freight": "15.42",
    "avg_freight_ratio": "24.17%"
  },
  {
    "category": "diapers_and_hygiene",
    "total_orders": "27",
    "total_gmv": "2141.27",
    "avg_review_score": "3.26",
    "avg_freight": "14.71",
    "avg_freight_ratio": "28.52%"
  },
  {
    "category": "flowers",
    "total_orders": "29",
    "total_gmv": "1598.91",
    "avg_review_score": "4.42",
    "avg_freight": "14.81",
    "avg_freight_ratio": "33.91%"
  },
  {
    "category": "home_comfort_2",
    "total_orders": "24",
    "total_gmv": "1170.58",
    "avg_review_score": "3.63",
    "avg_freight": "13.68",
    "avg_freight_ratio": "45.86%"
  },
  {
    "category": "cds_dvds_musicals",
    "total_orders": "12",
    "total_gmv": "954.99",
    "avg_review_score": "4.64",
    "avg_freight": "16.07",
    "avg_freight_ratio": "22.75%"
  },
  {
    "category": "fashion_childrens_clothes",
    "total_orders": "8",
    "total_gmv": "665.36",
    "avg_review_score": "4.50",
    "avg_freight": "11.94",
    "avg_freight_ratio": "16.02%"
  },
  {
    "category": "security_and_services",
    "total_orders": "2",
    "total_gmv": "324.51",
    "avg_review_score": "2.50",
    "avg_freight": "20.61",
    "avg_freight_ratio": "12.85%"
  }
]

*/