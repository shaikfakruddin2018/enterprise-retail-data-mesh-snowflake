{{ config(materialized='table', database='PRODUCT_DOMAIN_DB', schema='GOLD', alias='DIM_PRODUCTS') }}
select product_id, product_name, product_description, category, subcategory, brand, price, rating_avg, review_count, stock_quantity, date_added
from {{ ref('products_clean') }}
