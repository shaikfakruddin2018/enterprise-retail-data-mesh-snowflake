{{ config(materialized='view', database='MARKETING_DOMAIN_DB', schema='STAGING') }}
select *, current_timestamp() as load_timestamp, 'interactions.csv' as source_file, current_date() as load_date, 'marketing' as domain_name
from {{ source('raw_marketing','INTERACTIONS_RAW') }}
