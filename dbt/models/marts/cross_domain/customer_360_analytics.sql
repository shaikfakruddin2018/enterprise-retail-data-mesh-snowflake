{{ config(materialized='view', database='ANALYTICS_DB', schema='RETAIL_ANALYTICS', alias='CUSTOMER_360_ANALYTICS') }}
select c.*, clv.customer_value_segment, clv.first_purchase_date, clv.customer_purchase_span_days,
       c.converted_sessions/nullif(c.total_sessions,0) customer_conversion_rate
from {{ ref('customer_360') }} c left join {{ ref('customer_lifetime_value') }} clv on c.user_id=clv.user_id
