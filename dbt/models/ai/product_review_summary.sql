{{ config(materialized='table', database='AI_DATA_PRODUCTS_DB', schema='CORTEX_AI', alias='PRODUCT_REVIEW_SUMMARY') }}

-- Per-product review summary generated with Snowflake Cortex:
-- SNOWFLAKE.CORTEX.COMPLETE(model, prompt) over the product's aggregated reviews.
-- Fallback to a deterministic template with:  dbt build --vars 'use_cortex: false'

with agg as (
    select product_id, product_name, category, brand,
           count(*)                                   as review_count,
           avg(rating)                                as avg_rating,
           avg(sentiment_score)                       as avg_sentiment_score,
           count_if(sentiment_label = 'positive')     as positive_reviews,
           count_if(sentiment_label = 'neutral')      as neutral_reviews,
           count_if(sentiment_label = 'negative')     as negative_reviews
           {% if var('use_cortex', true) %}
           , listagg(review_text, ' || ') within group (order by review_date desc) as all_reviews
           {% endif %}
    from {{ ref('product_review_sentiment') }}
    group by product_id, product_name, category, brand
)

select product_id, product_name, category, brand, review_count, avg_rating, avg_sentiment_score,
       positive_reviews, neutral_reviews, negative_reviews,
{% if var('use_cortex', true) %}
       snowflake.cortex.complete(
           '{{ var("cortex_model", "llama3.1-8b") }}',
           'You are a product analyst. In two concise sentences, summarize customer sentiment for the product "'
           || product_name || '" for a product manager. Base it only on these reviews: '
           || left(all_reviews, 4000)
       ) as ai_review_summary,
       'SNOWFLAKE_CORTEX_COMPLETE' as ai_method
{% else %}
       case when avg_sentiment_score >=  0.4 then 'Customers are generally positive about this product.'
            when avg_sentiment_score <= -0.4 then 'Customers are generally negative about this product.'
            else 'Customer sentiment is mixed or neutral for this product.' end as ai_review_summary,
       'SQL_RULE_BASED_FALLBACK' as ai_method
{% endif %}
from agg
