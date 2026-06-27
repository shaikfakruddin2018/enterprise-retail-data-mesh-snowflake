{{ config(materialized='view', database='INVENTORY_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'inventory.csv' as source_file, current_date() as load_date, 'inventory' as domain_name
from {{ source('raw_inventory','INVENTORY_RAW') }}
