{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='CUSTOMER_OVERVIEW') }}
select customer_value_segment as segment, count(*) as customers,
       sum(lifetime_value)::float as revenue, avg(lifetime_value)::float as avg_clv,
       avg(iff(last_purchase_date < dateadd('day',-90,current_date()),1,0))::float as churn_rate,
       avg(purchase_count)::float as avg_orders
from {{ ref('customer_lifetime_value') }}
group by 1
