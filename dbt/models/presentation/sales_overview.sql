{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='SALES_OVERVIEW') }}
select f.order_date as date, coalesce(s.referrer_source,'Direct') as channel,
       sum(f.total_amount)::float as revenue, count(distinct f.order_id) as orders, sum(f.quantity) as units
from {{ ref('fct_sales') }} f
left join {{ ref('sessions_clean') }} s on f.session_id = s.session_id
group by 1,2
