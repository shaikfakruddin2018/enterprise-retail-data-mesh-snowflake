{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='GOLD', alias='USER_BEHAVIOR') }}
select s.user_id,count(distinct s.session_id) total_sessions,count(distinct i.interaction_id) total_interactions,count(distinct i.product_id) unique_products_viewed,avg(i.dwell_time_ms) avg_dwell_time_ms,count(distinct iff(s.is_converted=true,s.session_id,null)) converted_sessions,count(distinct p.purchase_id) purchases,coalesce(sum(p.total_amount),0) revenue
from {{ ref('sessions_clean') }} s left join {{ ref('interactions_clean') }} i on s.session_id=i.session_id left join {{ ref('purchases_clean') }} p on s.session_id=p.session_id
group by s.user_id
