{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='PRODUCT_KPI') }}
select 'Active SKUs' metric, count(*)::float value, 0::float delta from {{ ref('product_360') }}
union all select 'Avg Rating', avg(rating_avg), 0 from {{ ref('product_360') }}
union all select 'Total Units Sold', sum(total_units_sold), 0 from {{ ref('product_360') }}
union all select 'Out-of-Stock SKUs', count_if(total_stock_on_hand<=0), 0 from {{ ref('product_360') }}
