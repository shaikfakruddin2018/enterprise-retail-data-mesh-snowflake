{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='RETURNS_REFUNDS_OVERVIEW') }}
with r as (select category, count(distinct return_id) returns, sum(refund_amount) refund_amount from {{ ref('return_analytics') }} group by category),
s as (select category, count(distinct purchase_id) purchases from {{ ref('fct_sales') }} group by category)
select r.category, r.returns, r.refund_amount::float as refund_amount,
       (r.returns/nullif(s.purchases,0))::float as return_rate
from r left join s on r.category = s.category
