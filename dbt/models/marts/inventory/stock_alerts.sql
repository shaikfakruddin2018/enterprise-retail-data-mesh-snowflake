{{ config(materialized='table', database='INVENTORY_DOMAIN_DB', schema='GOLD', alias='STOCK_ALERTS') }}
select *, case when available_stock<=0 then 'out_of_stock' when stock_health_status='reorder_required' then 'low_stock' else 'normal' end alert_type
from {{ ref('inventory_status') }} where stock_health_status in ('reorder_required','watch') or available_stock<=0
