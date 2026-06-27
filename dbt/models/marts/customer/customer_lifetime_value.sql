{{ config(materialized='table', database='CUSTOMER_DOMAIN_DB', schema='GOLD', alias='CUSTOMER_LIFETIME_VALUE') }}
select c.user_id, c.country, c.city, c.loyalty_tier, count(distinct p.purchase_id) purchase_count,
       coalesce(sum(p.total_amount),0) lifetime_value, coalesce(avg(p.total_amount),0) avg_order_value,
       min(p.order_date) first_purchase_date, max(p.order_date) last_purchase_date,
       datediff('day', min(p.order_date), max(p.order_date)) customer_purchase_span_days,
       case when coalesce(sum(p.total_amount),0)>=5000 then 'high_value' when coalesce(sum(p.total_amount),0)>=1000 then 'medium_value' else 'low_value' end customer_value_segment
from {{ ref('customers_clean') }} c left join {{ ref('purchases_clean') }} p on c.user_id=p.user_id
group by c.user_id,c.country,c.city,c.loyalty_tier
