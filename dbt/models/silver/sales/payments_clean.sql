{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='SILVER', alias='PAYMENTS_CLEAN') }}
select trim(payment_id) payment_id, trim(order_id) order_id, trim(purchase_id) purchase_id, trim(user_id) user_id, try_to_timestamp_ntz(payment_ts) payment_ts, lower(trim(payment_method)) payment_method, lower(trim(payment_status)) payment_status, try_to_decimal(amount,18,2) amount, upper(trim(currency_code)) currency_code, trim(transaction_reference) transaction_reference, nullif(lower(trim(failure_reason)),'') failure_reason, try_to_decimal(fraud_score,18,2) fraud_score, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_sales__payments') }}
qualify row_number() over (partition by payment_id order by load_timestamp desc)=1
