{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='AI_COPILOT_CONTEXT') }}
select 'Revenue' as topic, 'Total Revenue' as metric, '$' || round(sum(gross_revenue)) as value,
       'Total gross revenue across all recorded sales.' as context, 'Sales' as domain from {{ ref('daily_sales') }}
union all select 'Customer','Active Customers', count_if(last_purchase_date >= dateadd('day',-90,current_date()))::string,
       'Customers with a purchase in the last 90 days.', 'Customer' from {{ ref('customer_360') }}
union all select 'Product','Top Product', max_by(product_name, total_revenue),
       'Highest-revenue product across the catalog.', 'Product' from {{ ref('product_360') }}
union all select 'Inventory','Critical Stock Alerts', count_if(available_stock<=0)::string,
       'SKUs currently out of stock.', 'Inventory' from {{ ref('inventory_status') }}
union all select 'Marketing','Best Channel (by conversions)', max_by(channel, conversions),
       'Channel driving the most conversions.', 'Marketing' from {{ ref('campaign_roi') }}
union all select 'Sales','Return Rate', round(100.0*count_if(is_returned)/nullif(count(*),0),1) || '%',
       'Share of sales that were returned.', 'Sales' from {{ ref('fct_sales') }}
