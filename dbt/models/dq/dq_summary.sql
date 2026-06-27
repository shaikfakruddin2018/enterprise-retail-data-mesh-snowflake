{{ config(materialized='view', database='DATA_QUALITY_DB', schema='DQ', alias='DQ_SUMMARY') }}

select 'CUSTOMERS_CLEAN' as model_name, count(*) as row_count from {{ ref('customers_clean') }}
union all select 'PRODUCTS_CLEAN', count(*) from {{ ref('products_clean') }}
union all select 'PURCHASES_CLEAN', count(*) from {{ ref('purchases_clean') }}
union all select 'INVENTORY_CLEAN', count(*) from {{ ref('inventory_clean') }}
union all select 'SESSIONS_CLEAN', count(*) from {{ ref('sessions_clean') }}
union all select 'FCT_SALES', count(*) from {{ ref('fct_sales') }}
