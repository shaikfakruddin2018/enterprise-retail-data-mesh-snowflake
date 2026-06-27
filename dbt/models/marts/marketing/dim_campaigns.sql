{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='GOLD', alias='DIM_CAMPAIGNS') }}
select campaign_id, campaign_name, channel, objective, start_date, end_date, budget_amount, currency_code, target_country, campaign_status
from {{ ref('campaigns_clean') }}
