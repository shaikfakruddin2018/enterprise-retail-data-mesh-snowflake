{{ config(materialized='table', database='AI_DATA_PRODUCTS_DB', schema='CORTEX_AI', alias='PRODUCT_REVIEW_SENTIMENT') }}

-- Review sentiment scored with Snowflake Cortex: SNOWFLAKE.CORTEX.SENTIMENT(text) -> float in [-1, 1].
-- Cortex is the default. On regions/accounts where Cortex is unavailable, run with the
-- deterministic fallback:  dbt build --vars 'use_cortex: false'

with base as (
    select r.review_id, r.user_id, r.product_id,
           p.product_name, p.category, p.brand,
           r.rating, r.title, r.review_text, r.review_date
    from {{ ref('reviews_clean') }} r
    left join {{ ref('products_clean') }} p on r.product_id = p.product_id
)

{% if var('use_cortex', true) %}
, scored as (
    select base.*, snowflake.cortex.sentiment(review_text) as sentiment_score
    from base
)
select review_id, user_id, product_id, product_name, category, brand,
       rating, title, review_text, review_date,
       sentiment_score,
       case when sentiment_score >=  0.3 then 'positive'
            when sentiment_score <= -0.3 then 'negative'
            else 'neutral' end as sentiment_label,
       'SNOWFLAKE_CORTEX_SENTIMENT' as ai_method
from scored
{% else %}
select review_id, user_id, product_id, product_name, category, brand,
       rating, title, review_text, review_date,
       case when rating >= 4 then 0.75 when rating = 3 then 0 when rating <= 2 then -0.75 else 0 end as sentiment_score,
       case when rating >= 4 then 'positive' when rating = 3 then 'neutral' when rating <= 2 then 'negative' else 'unknown' end as sentiment_label,
       'SQL_RULE_BASED_FALLBACK' as ai_method
from base
{% endif %}
