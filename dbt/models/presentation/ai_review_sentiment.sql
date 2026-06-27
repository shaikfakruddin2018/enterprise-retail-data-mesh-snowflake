{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='AI_REVIEW_SENTIMENT') }}
select product_name as product, review_count as reviews, avg_rating::float as avg_rating,
       (positive_reviews/nullif(review_count,0))::float as positive_pct,
       (negative_reviews/nullif(review_count,0))::float as negative_pct,
       ai_review_summary as summary
from {{ ref('product_review_summary') }}
