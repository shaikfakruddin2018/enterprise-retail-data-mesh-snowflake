{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='SILVER', alias='PURCHASES_CLEAN') }}
select trim(purchase_id) purchase_id, trim(order_id) order_id, trim(user_id) user_id, trim(product_id) product_id, trim(session_id) session_id, trim(interaction_id) interaction_id, try_to_number(quantity) quantity, try_to_decimal(unit_price,18,2) unit_price, try_to_decimal(total_amount,18,2) total_amount, try_to_date(order_date,'DD-MM-YYYY') order_date, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_sales__purchases') }}
where try_to_number(quantity)>0 and try_to_decimal(total_amount,18,2)>=0
qualify row_number() over (partition by purchase_id order by load_timestamp desc)=1
