{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='STOCK_ALERTS_OVERVIEW') }}
select product_name as product, warehouse_name as warehouse, stock_on_hand as stock_units, reorder_point,
       case when available_stock<=0 then 'Critical' when stock_health_status='reorder_required' then 'Low'
            when stock_health_status='watch' then 'Reorder' else 'Overstock' end as status,
       case when available_stock<=0 then 4 when stock_health_status='reorder_required' then 3
            when stock_health_status='watch' then 2 else 1 end as severity
from {{ ref('stock_alerts') }}
