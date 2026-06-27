{{ config(materialized='table', database='CUSTOMER_DOMAIN_DB', schema='GOLD', alias='CUSTOMER_SUPPORT_SUMMARY') }}
select c.user_id, c.country, c.loyalty_tier, count(distinct st.ticket_id) total_tickets,
       count(distinct iff(st.ticket_status='closed',st.ticket_id,null)) closed_tickets,
       count(distinct iff(st.priority='high',st.ticket_id,null)) high_priority_tickets,
       avg(st.satisfaction_score) avg_satisfaction_score, avg(datediff('hour',st.created_ts,st.closed_ts)) avg_resolution_hours, max(st.created_ts) latest_ticket_created_ts
from {{ ref('customers_clean') }} c left join {{ ref('support_tickets_clean') }} st on c.user_id=st.user_id
group by c.user_id,c.country,c.loyalty_tier
