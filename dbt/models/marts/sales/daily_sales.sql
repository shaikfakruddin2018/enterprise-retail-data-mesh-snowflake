{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='GOLD', alias='DAILY_SALES') }}
select order_date, count(distinct order_id) total_orders, count(distinct purchase_id) total_purchases, count(distinct user_id) unique_customers, sum(quantity) total_units_sold, sum(total_amount) gross_revenue, avg(total_amount) avg_purchase_value
from {{ ref('purchases_clean') }} group by order_date
