{{ config(materialized='table', database='INVENTORY_DOMAIN_DB', schema='SILVER', alias='WAREHOUSES_CLEAN') }}
select trim(warehouse_id) warehouse_id, trim(warehouse_name) warehouse_name, upper(trim(country)) country, upper(trim(state)) state, initcap(trim(city)) city, trim(postal_code) postal_code, trim(timezone) timezone, try_to_boolean(is_active) is_active, try_to_date(opened_date,'DD-MM-YYYY') opened_date, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_inventory__warehouses') }}
qualify row_number() over (partition by warehouse_id order by load_timestamp desc)=1
