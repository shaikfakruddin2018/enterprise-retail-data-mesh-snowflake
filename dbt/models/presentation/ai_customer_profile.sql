{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='AI_CUSTOMER_PROFILE') }}
select ai_customer_segment as segment, count(*) as customers, avg(lifetime_revenue)::float as avg_clv,
       case
         when ai_customer_segment ilike '%VIP happy%' then 'High-value, highly satisfied buyers with strong loyalty.'
         when ai_customer_segment ilike '%VIP at-risk%' then 'High-value but dissatisfied — elevated churn risk.'
         when ai_customer_segment ilike '%support-heavy%' then 'Engaged but high support burden; experience friction.'
         when ai_customer_segment ilike '%low engagement%' then 'Browsing without converting; weak engagement.'
         else 'Steady mainstream customers with average behaviour.' end as profile,
       case
         when ai_customer_segment ilike '%VIP happy%' then 'Reward with early access and referral incentives.'
         when ai_customer_segment ilike '%VIP at-risk%' then 'Prioritise win-back outreach and concierge support.'
         when ai_customer_segment ilike '%support-heavy%' then 'Fix root-cause issues; proactive support follow-up.'
         when ai_customer_segment ilike '%low engagement%' then 'Re-engage with personalised recommendations.'
         else 'Upsell premium tiers and bundles.' end as recommended_action
from {{ ref('customer_ai_experience_profile') }}
group by ai_customer_segment
