{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='AI_CAMPAIGN_INSIGHTS') }}
with top as (
  select campaign_name, channel, spend_amount, conversions,
         click_through_rate, conversion_rate, cost_per_conversion
  from {{ ref('campaign_roi') }}
  order by spend_amount desc nulls last
  limit 15
)
select campaign_name as campaign, channel,
{% if var('use_cortex', true) %}
  snowflake.cortex.complete('{{ var("cortex_model","llama3.1-8b") }}',
    'In one sentence, give a marketing insight for campaign "' || campaign_name || '" on ' || channel ||
    ' with CTR=' || coalesce(click_through_rate,0) || ', conversion_rate=' || coalesce(conversion_rate,0) ||
    ', cost_per_conversion=' || coalesce(cost_per_conversion,0) || '.') as insight,
  snowflake.cortex.complete('{{ var("cortex_model","llama3.1-8b") }}',
    'In one sentence, recommend the next action for campaign "' || campaign_name || '" on ' || channel ||
    ' given conversion_rate=' || coalesce(conversion_rate,0) || ' and cost_per_conversion=' || coalesce(cost_per_conversion,0) || '.') as recommendation,
{% else %}
  'CTR ' || round(coalesce(click_through_rate,0)*100,1) || '% with conversion rate ' || round(coalesce(conversion_rate,0)*100,1) || '%.' as insight,
  case when coalesce(cost_per_conversion,0) > 50 then 'Reduce spend or improve targeting to lower cost per conversion.'
       else 'Scale budget while efficiency holds.' end as recommendation,
{% endif %}
  conversion_rate::float as est_impact
from top
