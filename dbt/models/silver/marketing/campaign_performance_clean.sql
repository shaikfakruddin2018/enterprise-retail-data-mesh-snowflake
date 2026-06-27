{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='SILVER', alias='CAMPAIGN_PERFORMANCE_CLEAN') }}
select trim(campaign_id) campaign_id, try_to_number(sessions) sessions, try_to_number(conversions) conversions, try_to_decimal(spend_amount,18,2) spend_amount, try_to_number(impressions) impressions, try_to_number(clicks) clicks, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_marketing__campaign_performance') }}
qualify row_number() over (partition by campaign_id order by load_timestamp desc)=1
