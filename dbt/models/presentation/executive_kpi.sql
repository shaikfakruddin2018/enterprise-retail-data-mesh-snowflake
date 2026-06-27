{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='EXECUTIVE_KPI') }}
with r as (
  select revenue_month, gross_revenue, total_orders, avg_purchase_value, unique_customers,
         row_number() over (order by revenue_month desc) rn
  from {{ ref('monthly_revenue') }}
),
cur as (select * from r where rn=1), prev as (select * from r where rn=2)
select 'Total Revenue' metric, cur.gross_revenue::float value, ((cur.gross_revenue-prev.gross_revenue)/nullif(prev.gross_revenue,0))::float delta from cur,prev
union all select 'Orders', cur.total_orders, (cur.total_orders-prev.total_orders)/nullif(prev.total_orders,0) from cur,prev
union all select 'Avg Order Value', cur.avg_purchase_value, (cur.avg_purchase_value-prev.avg_purchase_value)/nullif(prev.avg_purchase_value,0) from cur,prev
union all select 'Active Customers', cur.unique_customers, (cur.unique_customers-prev.unique_customers)/nullif(prev.unique_customers,0) from cur,prev
