{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='SILVER', alias='CAMPAIGNS_CLEAN') }}
select trim(campaign_id) campaign_id, trim(campaign_name) campaign_name, lower(trim(channel)) channel, lower(trim(objective)) objective, try_to_date(start_date,'DD-MM-YYYY') start_date, try_to_date(end_date,'DD-MM-YYYY') end_date, try_to_decimal(budget_amount,18,2) budget_amount, upper(trim(currency_code)) currency_code, upper(trim(target_country)) target_country, lower(trim(campaign_status)) campaign_status, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_marketing__campaigns') }}
qualify row_number() over (partition by campaign_id order by load_timestamp desc)=1
