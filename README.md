# Olist E-Commerce SQL & Power BI Analysis

## Project Overview
This project analyzes the **Olist e-commerce dataset** to evaluate business performance, customer behavior, delivery operations, seller quality, and product category trends.  

The workflow combines **Python for data cleaning**, **PostgreSQL for database design and SQL analysis**, and **Power BI for dashboard visualization**.

## Objectives
The main goals of this project were to:
- clean and prepare raw Olist data for analysis
- build a structured relational database in PostgreSQL
- write SQL queries to answer business questions
- visualize key insights in Power BI
- create an end-to-end analytics project that demonstrates data cleaning, database design, SQL, and BI reporting skills

## Tools Used
- **Python** — data cleaning and preprocessing
- **PostgreSQL / pgAdmin** — table creation, data import, and SQL querying
- **VS Code** — writing and organizing SQL queries
- **Power BI** — dashboard creation and business visualization

## Workflow
### 1) Data Cleaning in Python
I first used Python to clean and prepare the raw Olist dataset before loading it into PostgreSQL. This included:
- handling missing values
- standardizing formats
- converting date fields into timestamp-ready formats
- creating analysis-ready derived columns such as:
  - `order_month`
  - `order_year`
  - `delivery_days`
  - `estimated_delivery_days`
  - `is_delivered`
  - `is_late`
  - `item_total_value`
  - `freight_ratio`
  - `review_group`

### 2) Database Setup in PostgreSQL
After cleaning the data, I created tables in PostgreSQL and imported the prepared datasets through pgAdmin.

### 3) SQL Analysis in VS Code
I then wrote SQL queries in VS Code to answer business questions related to:
- sales performance
- monthly growth trends
- geographic performance
- category performance
- delivery speed and customer satisfaction
- seller portfolio segmentation
- customer portfolio and repeat purchase behavior

### 4) Dashboard Development in Power BI
Finally, I used Power BI to visualize the SQL results in an interactive dashboard. The dashboard highlights business growth, customer experience, operational performance, and commercial insights.

## Database Schema
The project uses the following core tables:

### `olist_orders`
Stores order-level information, including status and delivery timing.

```sql
CREATE TABLE olist_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    order_month INTEGER,
    order_year INTEGER,
    delivery_days INTEGER,
    estimated_delivery_days INTEGER,
    is_delivered BOOLEAN,
    is_late BOOLEAN
);
```

### `olist_order_items`
Stores product-level order details, prices, freight, and item value.

```sql
CREATE TABLE olist_order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    item_total_value NUMERIC(10,2),
    freight_ratio NUMERIC(10,4),
    PRIMARY KEY (order_id, order_item_id)
);
```

### `olist_order_reviews`
Stores customer review scores and review text.

```sql
CREATE TABLE olist_order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    review_group VARCHAR(20)
);
```

### `olist_products`
Stores product attributes and English category names.

```sql
CREATE TABLE olist_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER,
    product_category_name_english VARCHAR(100)
);
```

### `olist_customers`
Stores customer identity and location information.

```sql
CREATE TABLE olist_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
```

### `olist_sellers`
Stores seller identity and location information.

```sql
CREATE TABLE olist_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);
```

## Key Business Questions
Examples of questions explored in this project include:
- How many total orders were placed, and what was the delivery rate?
- How did monthly orders and GMV change over time?
- Which states generated the most orders and GMV?
- How did delivery speed affect review scores and negative feedback?
- Which product categories drove the most revenue?
- How can sellers be segmented into top-tier, ordinary, and high-risk groups?
- What does the customer portfolio say about repeat purchasing and retention?

## Example Insights
Some of the main findings from the analysis include:
- the business showed strong growth in both monthly orders and GMV over time
- sales were concentrated in a few major states, especially São Paulo
- longer delivery times were strongly associated with lower review scores
- a small number of product categories drove a large share of sales
- most sellers were classified as ordinary sellers and contributed most of total GMV
- repeat customer rate was low, suggesting customer retention could be improved

## Power BI Dashboard
The Power BI dashboard was built to communicate the main results from the SQL analysis. Suggested sections include:
- **Executive KPIs:** total orders, delivered orders, delivery rate, GMV, AOV
- **Monthly Trend Analysis:** monthly orders and monthly GMV
- **Geographic Performance:** orders and GMV by state
- **Delivery vs Satisfaction:** delivery windows compared with average review score
- **Category Insights:** top categories by GMV and order volume
- **Customer Portfolio:** repeat rate and customer value indicators

## Project Structure
```text
olist-project/
├── data/
│   ├── raw/
│   └── cleaned/
├── notebooks/
│   └── data_cleaning.ipynb
├── sql/
│   ├── create_tables.sql
│   ├── import_data.sql
│   └── analysis_queries.sql
├── powerbi/
│   └── dashboard.pbix
└── README.md
```

## What This Project Demonstrates
This project highlights:
- data cleaning and feature creation in Python
- relational database design in PostgreSQL
- SQL querying for business analysis
- translating query results into business insights
- dashboard design and storytelling in Power BI

## Future Improvements
Possible next steps for this project include:
- adding indexes and query optimization in PostgreSQL
- building more advanced customer segmentation models
- performing cohort or retention analysis
- adding seller- and category-level drilldowns in Power BI
- automating the data pipeline from cleaning to dashboard refresh

## Conclusion
This project is an end-to-end e-commerce analytics case study that combines **Python, PostgreSQL, SQL, and Power BI** to transform raw transactional data into actionable business insights. It demonstrates both technical data skills and the ability to communicate findings through dashboards and structured analysis.
