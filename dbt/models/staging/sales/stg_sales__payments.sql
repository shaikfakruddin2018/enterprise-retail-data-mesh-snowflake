{{ config(materialized='view', database='SALES_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'payments.csv' as source_file, current_date() as load_date, 'sales' as domain_name
from {{ source('raw_sales','PAYMENTS_RAW') }}
