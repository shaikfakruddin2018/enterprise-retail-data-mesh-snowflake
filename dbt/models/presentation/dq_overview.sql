{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='DQ_OVERVIEW') }}
select 'Models Monitored' metric, count(*)::float value, 0::float delta from {{ ref('dq_summary') }}
union all select 'Total Rows Tracked', sum(row_count), 0 from {{ ref('dq_summary') }}
union all select 'Smallest Model (rows)', min(row_count), 0 from {{ ref('dq_summary') }}
union all select 'Largest Model (rows)', max(row_count), 0 from {{ ref('dq_summary') }}
