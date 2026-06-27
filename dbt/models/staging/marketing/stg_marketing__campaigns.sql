{{ config(materialized='view', database='MARKETING_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'campaigns.csv' as source_file, current_date() as load_date, 'marketing' as domain_name
from {{ source('raw_marketing','CAMPAIGNS_RAW') }}
