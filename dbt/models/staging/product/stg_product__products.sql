{{ config(materialized='view', database='PRODUCT_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'products.csv' as source_file, current_date() as load_date, 'product' as domain_name
from {{ source('raw_product','PRODUCTS_RAW') }}
