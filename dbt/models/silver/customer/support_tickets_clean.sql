{{ config(materialized='table', database='CUSTOMER_DOMAIN_DB', schema='SILVER', alias='SUPPORT_TICKETS_CLEAN') }}
select trim(ticket_id) ticket_id, trim(user_id) user_id, trim(order_id) order_id, trim(product_id) product_id, try_to_timestamp_ntz(created_ts) created_ts, try_to_timestamp_ntz(closed_ts) closed_ts, lower(trim(ticket_channel)) ticket_channel, lower(trim(ticket_category)) ticket_category, lower(trim(priority)) priority, lower(trim(ticket_status)) ticket_status, trim(subject) subject, try_to_number(satisfaction_score) satisfaction_score, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_customer__support_tickets') }}
qualify row_number() over (partition by ticket_id order by load_timestamp desc)=1
