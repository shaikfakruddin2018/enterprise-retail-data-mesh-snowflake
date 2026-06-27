{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='PRODUCT_OVERVIEW') }}
select p.product_name as product, p.category,
       p.total_revenue::float as revenue, p.total_units_sold as units_sold,
       pp.return_rate::float as margin_pct, p.rating_avg::float as avg_rating
from {{ ref('product_360') }} p
left join {{ ref('product_performance') }} pp on p.product_id = pp.product_id
order by p.total_revenue desc
