{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='GOLD', alias='MONTHLY_REVENUE') }}
select date_trunc('month',order_date) revenue_month, count(distinct order_id) total_orders, count(distinct user_id) unique_customers, sum(quantity) total_units_sold, sum(total_amount) gross_revenue, avg(total_amount) avg_purchase_value
from {{ ref('purchases_clean') }} group by date_trunc('month',order_date)
