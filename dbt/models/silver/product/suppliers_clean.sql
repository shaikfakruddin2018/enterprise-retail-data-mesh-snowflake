{{ config(materialized='table', database='PRODUCT_DOMAIN_DB', schema='SILVER', alias='SUPPLIERS_CLEAN') }}
select trim(supplier_id) supplier_id, trim(supplier_name) supplier_name, initcap(trim(brand)) brand, initcap(trim(primary_category)) primary_category, upper(trim(country)) country, initcap(trim(city)) city, lower(trim(supplier_status)) supplier_status, try_to_number(lead_time_days) lead_time_days, try_to_decimal(quality_score,18,2) quality_score, try_to_date(created_at,'DD-MM-YYYY') created_at, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_product__suppliers') }}
qualify row_number() over (partition by supplier_id order by load_timestamp desc)=1
