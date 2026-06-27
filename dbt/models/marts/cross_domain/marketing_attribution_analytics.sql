{{ config(materialized='view', database='ANALYTICS_DB', schema='RETAIL_ANALYTICS', alias='MARKETING_ATTRIBUTION_ANALYTICS') }}
select *, attributed_revenue/nullif(total_purchases,0) revenue_per_purchase, attributed_revenue/nullif(total_sessions,0) revenue_per_session
from {{ ref('conversion_funnel') }}
