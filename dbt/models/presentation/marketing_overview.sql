{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='MARKETING_OVERVIEW') }}
with aov as (select avg(total_amount) v from {{ ref('fct_sales') }})
select c.channel,
       sum(c.spend_amount)::float as spend, sum(c.impressions) as impressions, sum(c.clicks) as clicks,
       sum(c.conversions) as conversions,
       (sum(c.conversions) * (select v from aov))::float as revenue,
       ((sum(c.conversions) * (select v from aov)) / nullif(sum(c.spend_amount),0))::float as roas
from {{ ref('campaign_roi') }} c
group by c.channel
