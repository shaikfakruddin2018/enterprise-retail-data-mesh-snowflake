{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='GOLD', alias='CAMPAIGN_ROI') }}
select c.campaign_id,c.campaign_name,c.channel,c.objective,c.start_date,c.end_date,c.budget_amount,c.currency_code,c.target_country,c.campaign_status,
       cp.sessions,cp.conversions,cp.spend_amount,cp.impressions,cp.clicks,
       cp.clicks/nullif(cp.impressions,0) click_through_rate, cp.conversions/nullif(cp.sessions,0) conversion_rate, cp.spend_amount/nullif(cp.conversions,0) cost_per_conversion
from {{ ref('campaigns_clean') }} c left join {{ ref('campaign_performance_clean') }} cp on c.campaign_id=cp.campaign_id
