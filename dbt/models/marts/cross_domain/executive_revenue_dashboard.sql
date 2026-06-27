{{ config(materialized='view', database='ANALYTICS_DB', schema='RETAIL_ANALYTICS', alias='EXECUTIVE_REVENUE_DASHBOARD') }}
select ds.order_date, date_trunc('month', ds.order_date) revenue_month, ds.total_orders, ds.total_purchases, ds.unique_customers, ds.total_units_sold, ds.gross_revenue, ds.avg_purchase_value,
       count(distinct sf.product_id) unique_products_sold, count(distinct sf.customer_country) active_countries,
       sum(iff(sf.is_returned=true,sf.total_amount,0)) returned_revenue, sum(iff(sf.is_refunded=true,sf.refund_amount,0)) refunded_amount,
       ds.gross_revenue-coalesce(sum(iff(sf.is_refunded=true,sf.refund_amount,0)),0) net_revenue
from {{ ref('daily_sales') }} ds left join {{ ref('fct_sales') }} sf on ds.order_date=sf.order_date
group by ds.order_date,date_trunc('month',ds.order_date),ds.total_orders,ds.total_purchases,ds.unique_customers,ds.total_units_sold,ds.gross_revenue,ds.avg_purchase_value
