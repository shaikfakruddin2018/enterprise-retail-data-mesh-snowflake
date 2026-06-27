{{ config(materialized='view', database='INVENTORY_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'warehouses.csv' as source_file, current_date() as load_date, 'inventory' as domain_name
from {{ source('raw_inventory','WAREHOUSES_RAW') }}
