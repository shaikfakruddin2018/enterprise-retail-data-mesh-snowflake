{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='SALES_COUNTRY_CATEGORY') }}
select customer_country as country, category,
       sum(gross_revenue)::float as revenue, sum(total_orders) as orders, sum(total_units_sold) as units
from {{ ref('sales_by_country_category_month') }}
group by 1,2
