{{ config(materialized='table', database='PRODUCT_DOMAIN_DB', schema='SILVER', alias='REVIEWS_CLEAN') }}
select trim(review_id) review_id, trim(user_id) user_id, trim(product_id) product_id, trim(purchase_id) purchase_id, try_to_number(rating) rating, trim(title) title, trim(review_text) review_text, try_to_date(review_date,'DD-MM-YYYY') review_date, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_product__reviews') }}
qualify row_number() over (partition by review_id order by load_timestamp desc)=1
