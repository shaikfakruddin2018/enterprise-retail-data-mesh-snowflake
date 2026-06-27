{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='INVENTORY_OVERVIEW') }}
select i.warehouse_name as warehouse, i.category,
       sum(i.stock_on_hand) as stock_units,
       sum(i.stock_on_hand * coalesce(p.price,0))::float as stock_value,
       (sum(i.available_stock) / nullif(sum(i.reorder_point),0))::float as days_of_supply
from {{ ref('inventory_status') }} i
left join {{ ref('dim_products') }} p on i.product_id = p.product_id
group by 1,2
