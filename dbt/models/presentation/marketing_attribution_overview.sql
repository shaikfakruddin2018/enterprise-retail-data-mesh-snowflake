{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='MARKETING_ATTRIBUTION_OVERVIEW') }}
with f as (
  select referrer_source as channel, sum(attributed_revenue) attributed_revenue,
         sum(total_purchases) conversions,
         avg(total_interactions / nullif(total_sessions,0)) avg_touchpoints
  from {{ ref('conversion_funnel') }} group by referrer_source
)
select channel, attributed_revenue::float as attributed_revenue, conversions,
       avg_touchpoints::float as avg_touchpoints,
       (attributed_revenue / nullif((select sum(attributed_revenue) from f),0))::float as attribution_share
from f
