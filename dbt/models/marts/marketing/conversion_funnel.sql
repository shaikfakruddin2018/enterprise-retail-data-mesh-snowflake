{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='GOLD', alias='CONVERSION_FUNNEL') }}
select s.referrer_source,s.device_type,count(distinct s.session_id) total_sessions,count(distinct iff(s.is_converted=true,s.session_id,null)) converted_sessions,count(distinct i.interaction_id) total_interactions,count(distinct p.purchase_id) total_purchases,coalesce(sum(p.total_amount),0) attributed_revenue,
       count(distinct iff(s.is_converted=true,s.session_id,null))/nullif(count(distinct s.session_id),0) session_conversion_rate
from {{ ref('sessions_clean') }} s left join {{ ref('interactions_clean') }} i on s.session_id=i.session_id left join {{ ref('purchases_clean') }} p on s.session_id=p.session_id
group by s.referrer_source,s.device_type
