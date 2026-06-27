{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='CUSTOMER_KPI') }}
select 'Active Customers' metric, count_if(last_purchase_date >= dateadd('day',-90,current_date()))::float value, 0::float delta from {{ ref('customer_360') }}
union all select 'Avg Customer LTV', (select avg(lifetime_value) from {{ ref('customer_lifetime_value') }}), 0
union all select 'Avg Orders / Customer', avg(total_orders), 0 from {{ ref('customer_360') }}
union all select 'Repeat Purchase Rate', avg(iff(total_purchases>1,1,0)), 0 from {{ ref('customer_360') }}
