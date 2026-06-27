{{ config(materialized='view', database='MARKETING_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'campaign_performance.csv' as source_file, current_date() as load_date, 'marketing' as domain_name
from {{ source('raw_marketing','CAMPAIGN_PERFORMANCE_RAW') }}
