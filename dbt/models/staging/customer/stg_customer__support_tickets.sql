{{ config(materialized='view', database='CUSTOMER_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'support_tickets.csv' as source_file, current_date() as load_date, 'customer' as domain_name
from {{ source('raw_customer','SUPPORT_TICKETS_RAW') }}
