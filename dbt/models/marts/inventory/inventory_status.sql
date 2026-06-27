{{ config(materialized='table', database='INVENTORY_DOMAIN_DB', schema='GOLD', alias='INVENTORY_STATUS') }}
select i.inventory_id,i.product_id,p.product_name,p.category,p.brand,i.warehouse_id,w.warehouse_name,w.country,w.city,i.stock_on_hand,i.reserved_quantity,i.reorder_point,i.reorder_quantity,i.inventory_status,i.last_stocktake_date,
       i.stock_on_hand-i.reserved_quantity available_stock,
       case when i.stock_on_hand<=i.reorder_point then 'reorder_required' when i.stock_on_hand<=i.reorder_point*1.5 then 'watch' else 'healthy' end stock_health_status
from {{ ref('inventory_clean') }} i left join {{ ref('products_clean') }} p on i.product_id=p.product_id left join {{ ref('warehouses_clean') }} w on i.warehouse_id=w.warehouse_id
