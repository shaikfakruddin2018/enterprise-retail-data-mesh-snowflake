{{ config(materialized='table', database='INVENTORY_DOMAIN_DB', schema='GOLD', alias='SHIPPING_PERFORMANCE') }}
select s.shipment_id,s.order_id,s.purchase_id,s.user_id,s.warehouse_id,w.warehouse_name,w.country,w.city,s.carrier,s.shipment_status,s.shipped_ts,s.promised_delivery_ts,s.delivered_ts,s.is_late,s.shipping_cost,
       datediff('day',s.shipped_ts,s.delivered_ts) delivery_days, datediff('hour',s.promised_delivery_ts,s.delivered_ts) delivery_delay_hours
from {{ ref('shipments_clean') }} s left join {{ ref('warehouses_clean') }} w on s.warehouse_id=w.warehouse_id
