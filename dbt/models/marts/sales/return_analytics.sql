{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='GOLD', alias='RETURN_ANALYTICS') }}
select r.return_id,r.order_id,r.purchase_id,r.user_id,r.product_id,r.return_ts,r.return_reason,r.return_status,r.quantity_returned,r.condition_received,
       p.total_amount original_purchase_amount, rf.refund_amount, rf.refund_status, rf.refund_method, pr.category, pr.brand
from {{ ref('returns_clean') }} r
left join {{ ref('purchases_clean') }} p on r.purchase_id=p.purchase_id
left join {{ ref('refunds_clean') }} rf on r.return_id=rf.return_id
left join {{ ref('products_clean') }} pr on r.product_id=pr.product_id
