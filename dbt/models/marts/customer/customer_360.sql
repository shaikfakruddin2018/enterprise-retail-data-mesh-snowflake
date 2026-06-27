{{ config(materialized='table', database='CUSTOMER_DOMAIN_DB', schema='GOLD', alias='CUSTOMER_360') }}
select c.user_id, c.age, c.gender, c.country, c.city, c.signup_date, c.income_level, c.preferred_category, c.loyalty_tier,
       count(distinct p.purchase_id) total_purchases, count(distinct p.order_id) total_orders,
       coalesce(sum(p.total_amount),0) lifetime_revenue, coalesce(avg(p.total_amount),0) avg_purchase_value, max(p.order_date) last_purchase_date,
       count(distinct st.ticket_id) total_support_tickets, avg(st.satisfaction_score) avg_satisfaction_score,
       count(distinct s.session_id) total_sessions, count(distinct iff(s.is_converted=true,s.session_id,null)) converted_sessions
from {{ ref('customers_clean') }} c
left join {{ ref('purchases_clean') }} p on c.user_id=p.user_id
left join {{ ref('support_tickets_clean') }} st on c.user_id=st.user_id
left join {{ ref('sessions_clean') }} s on c.user_id=s.user_id
group by c.user_id,c.age,c.gender,c.country,c.city,c.signup_date,c.income_level,c.preferred_category,c.loyalty_tier
