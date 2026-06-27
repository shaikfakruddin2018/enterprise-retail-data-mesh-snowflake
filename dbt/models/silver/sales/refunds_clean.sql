{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='SILVER', alias='REFUNDS_CLEAN') }}
select trim(refund_id) refund_id, trim(return_id) return_id, trim(order_id) order_id, trim(purchase_id) purchase_id, trim(user_id) user_id, try_to_timestamp_ntz(refund_ts) refund_ts, lower(trim(refund_status)) refund_status, lower(trim(refund_method)) refund_method, try_to_decimal(refund_amount,18,2) refund_amount, upper(trim(currency_code)) currency_code, lower(trim(refund_reason)) refund_reason, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_sales__refunds') }}
qualify row_number() over (partition by refund_id order by load_timestamp desc)=1
