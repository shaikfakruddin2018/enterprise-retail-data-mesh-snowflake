{{ config(materialized='table', database='INVENTORY_DOMAIN_DB', schema='GOLD', alias='DIM_WAREHOUSES') }}
select warehouse_id, warehouse_name, country, state, city, postal_code, timezone, is_active, opened_date
from {{ ref('warehouses_clean') }}
