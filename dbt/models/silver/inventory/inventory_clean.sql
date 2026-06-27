{{ config(materialized='table', database='INVENTORY_DOMAIN_DB', schema='SILVER', alias='INVENTORY_CLEAN') }}
select trim(inventory_id) inventory_id, trim(product_id) product_id, trim(warehouse_id) warehouse_id, try_to_number(stock_on_hand) stock_on_hand, try_to_number(reserved_quantity) reserved_quantity, try_to_number(reorder_point) reorder_point, try_to_number(reorder_quantity) reorder_quantity, lower(trim(inventory_status)) inventory_status, try_to_date(last_stocktake_date,'DD-MM-YYYY') last_stocktake_date, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_inventory__inventory') }}
qualify row_number() over (partition by inventory_id order by load_timestamp desc)=1
