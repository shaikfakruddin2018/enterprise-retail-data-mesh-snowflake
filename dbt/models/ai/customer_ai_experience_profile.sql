{{ config(materialized='table', database='AI_DATA_PRODUCTS_DB', schema='CORTEX_AI', alias='CUSTOMER_AI_EXPERIENCE_PROFILE') }}

-- Customer experience segmentation with Snowflake Cortex:
-- SNOWFLAKE.CORTEX.COMPLETE(model, prompt) constrained to a fixed label set.
-- Fallback to deterministic rules with:  dbt build --vars 'use_cortex: false'

select user_id, country, city, loyalty_tier,
       total_purchases, lifetime_revenue, avg_purchase_value,
       total_support_tickets, avg_satisfaction_score,
       total_sessions, converted_sessions,
{% if var('use_cortex', true) %}
       trim(snowflake.cortex.complete(
           '{{ var("cortex_model", "llama3.1-8b") }}',
           'Classify this retail customer into exactly one label from this set and reply with only the label: '
           || '[VIP happy customer, VIP at-risk customer, support-heavy customer, low engagement customer, standard customer]. '
           || 'Customer data: lifetime_revenue=' || coalesce(lifetime_revenue, 0)
           || ', avg_satisfaction=' || coalesce(avg_satisfaction_score, 0)
           || ', support_tickets=' || coalesce(total_support_tickets, 0)
           || ', converted_sessions=' || coalesce(converted_sessions, 0)
           || ', loyalty_tier=' || coalesce(loyalty_tier, 'unknown')
       )) as ai_customer_segment,
       'SNOWFLAKE_CORTEX_COMPLETE' as ai_method
{% else %}
       case when lifetime_revenue >= 5000 and avg_satisfaction_score >= 4 then 'VIP happy customer'
            when lifetime_revenue >= 5000 and avg_satisfaction_score <  4 then 'VIP at-risk customer'
            when total_support_tickets >= 3 then 'support-heavy customer'
            when converted_sessions = 0 then 'low engagement customer'
            else 'standard customer' end as ai_customer_segment,
       'SQL_RULE_BASED_FALLBACK' as ai_method
{% endif %}
from {{ ref('customer_360') }}
