{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='SILVER', alias='RETURNS_CLEAN') }}
select trim(return_id) return_id, trim(order_id) order_id, trim(purchase_id) purchase_id, trim(shipment_id) shipment_id, trim(user_id) user_id, trim(product_id) product_id, try_to_timestamp_ntz(return_ts) return_ts, lower(trim(return_reason)) return_reason, lower(trim(return_status)) return_status, try_to_number(quantity_returned) quantity_returned, lower(trim(condition_received)) condition_received, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_sales__returns') }}
qualify row_number() over (partition by return_id order by load_timestamp desc)=1
