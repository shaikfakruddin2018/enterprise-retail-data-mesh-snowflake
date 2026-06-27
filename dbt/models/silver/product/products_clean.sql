{{ config(materialized='table', database='PRODUCT_DOMAIN_DB', schema='SILVER', alias='PRODUCTS_CLEAN') }}
select trim(product_id) product_id, trim(product_name) product_name, trim(product_description) product_description, initcap(trim(category)) category, initcap(trim(subcategory)) subcategory, initcap(trim(brand)) brand, try_to_decimal(price,18,2) price, try_to_decimal(rating_avg,18,2) rating_avg, try_to_number(review_count) review_count, try_to_number(stock_quantity) stock_quantity, try_to_date(date_added,'DD-MM-YYYY') date_added, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_product__products') }}
qualify row_number() over (partition by product_id order by load_timestamp desc)=1
