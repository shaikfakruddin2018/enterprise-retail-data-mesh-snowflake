{{ config(materialized='view', database='ANALYTICS_DB', schema='RETAIL_ANALYTICS', alias='SALES_BY_COUNTRY_CATEGORY_MONTH') }}
select date_trunc('month',order_date) sales_month, customer_country, category, subcategory, brand, count(distinct order_id) total_orders, count(distinct purchase_id) total_purchases, count(distinct user_id) unique_customers, sum(quantity) total_units_sold, sum(total_amount) gross_revenue,
       sum(iff(is_returned=true,total_amount,0)) returned_revenue, sum(iff(is_refunded=true,refund_amount,0)) refunded_amount, sum(total_amount)-coalesce(sum(iff(is_refunded=true,refund_amount,0)),0) net_revenue
from {{ ref('fct_sales') }} group by date_trunc('month',order_date), customer_country, category, subcategory, brand
