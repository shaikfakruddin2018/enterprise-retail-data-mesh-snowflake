{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='ENTERPRISE_SEARCH') }}
select 'Customer' as entity_type,
       'Customer ' || user_id || ' — ' || coalesce(loyalty_tier,'n/a') as title,
       'Lifetime revenue $' || round(coalesce(lifetime_revenue,0)) || ', ' || coalesce(total_purchases,0) || ' purchases.' as content,
       'Customer' as domain, last_purchase_date::timestamp as updated_at, 0.90::float as relevance
from {{ ref('customer_360') }}
union all
select 'Product', product_name, 'Revenue $' || round(coalesce(total_revenue,0)) || ', rating ' || coalesce(rating_avg,0) || '.', 'Product', current_timestamp(), 0.85
from {{ ref('product_360') }}
union all
select 'Campaign', campaign_name, 'Channel ' || channel || ', ' || coalesce(conversions,0) || ' conversions.', 'Marketing', current_timestamp(), 0.80
from {{ ref('campaign_roi') }}
union all
select 'Product', product_name, ai_review_summary, 'Product', current_timestamp(), 0.82
from {{ ref('product_review_summary') }}
