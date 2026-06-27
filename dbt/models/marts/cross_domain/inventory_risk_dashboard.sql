{{ config(materialized='view', database='ANALYTICS_DB', schema='RETAIL_ANALYTICS', alias='INVENTORY_RISK_DASHBOARD') }}
select i.*, pp.total_units_sold, pp.total_revenue,
       case when i.available_stock<=0 then 'critical' when i.stock_health_status='reorder_required' then 'high' when i.stock_health_status='watch' then 'medium' else 'low' end inventory_risk_level
from {{ ref('inventory_status') }} i left join {{ ref('product_360') }} pp on i.product_id=pp.product_id
