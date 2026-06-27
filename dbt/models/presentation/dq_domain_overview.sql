{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='DQ_DOMAIN_OVERVIEW') }}
select case
         when model_name ilike '%CUSTOMER%' or model_name ilike '%SUPPORT%' then 'Customer'
         when model_name ilike '%PRODUCT%' or model_name ilike '%REVIEW%' then 'Product'
         when model_name ilike '%SALES%' or model_name ilike '%PURCHASE%' or model_name ilike '%FCT%' or model_name ilike '%PAYMENT%' or model_name ilike '%REFUND%' or model_name ilike '%RETURN%' then 'Sales'
         when model_name ilike '%INVENTORY%' or model_name ilike '%WAREHOUSE%' or model_name ilike '%SHIPMENT%' then 'Inventory'
         when model_name ilike '%SESSION%' or model_name ilike '%CAMPAIGN%' or model_name ilike '%INTERACTION%' then 'Marketing'
         else 'Other' end as domain,
       1.0::float as quality_score, sum(row_count) as records, 0 as failures
from {{ ref('dq_summary') }}
group by 1
