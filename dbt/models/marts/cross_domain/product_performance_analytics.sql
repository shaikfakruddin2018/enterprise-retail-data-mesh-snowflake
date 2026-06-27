{{ config(materialized='view', database='ANALYTICS_DB', schema='RETAIL_ANALYTICS', alias='PRODUCT_PERFORMANCE_ANALYTICS') }}
select p.*, pp.return_count, pp.return_rate, pp.performance_segment,
       case when p.total_stock_on_hand<=0 then 'out_of_stock' when p.total_stock_on_hand<=10 then 'low_stock' else 'in_stock' end product_stock_status
from {{ ref('product_360') }} p left join {{ ref('product_performance') }} pp on p.product_id=pp.product_id
