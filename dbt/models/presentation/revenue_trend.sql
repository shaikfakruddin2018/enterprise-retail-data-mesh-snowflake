{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='REVENUE_TREND') }}
select date_trunc('month', order_date)::date as date,
       sum(gross_revenue)::float as revenue,
       sum(total_orders) as orders,
       (sum(net_revenue)/nullif(sum(gross_revenue),0))::float as gross_margin
from {{ ref('executive_revenue_dashboard') }}
group by 1 order by 1
