{{ config(materialized='table', database='INVENTORY_DOMAIN_DB', schema='SILVER', alias='SHIPMENTS_CLEAN') }}
select trim(shipment_id) shipment_id, trim(order_id) order_id, trim(purchase_id) purchase_id, trim(user_id) user_id, trim(warehouse_id) warehouse_id, trim(carrier) carrier, trim(tracking_number) tracking_number, lower(trim(shipment_status)) shipment_status, try_to_timestamp_ntz(shipped_ts) shipped_ts, try_to_timestamp_ntz(promised_delivery_ts) promised_delivery_ts, try_to_timestamp_ntz(delivered_ts) delivered_ts, try_to_boolean(is_late) is_late, try_to_decimal(shipping_cost,18,2) shipping_cost, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_inventory__shipments') }}
qualify row_number() over (partition by shipment_id order by load_timestamp desc)=1
