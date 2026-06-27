{{ config(materialized='table', database='SALES_DOMAIN_DB', schema='GOLD', alias='FCT_SALES') }}
select p.purchase_id, p.order_id, p.user_id, p.product_id, p.session_id, p.interaction_id, p.quantity, p.unit_price, p.total_amount, p.order_date,
       c.country as customer_country, c.city as customer_city, c.loyalty_tier,
       pr.product_name, pr.category, pr.subcategory, pr.brand,
       pay.payment_method, pay.payment_status, pay.currency_code, pay.fraud_score,
       iff(r.return_id is not null,true,false) as is_returned, r.return_reason, r.return_status,
       iff(rf.refund_id is not null,true,false) as is_refunded, rf.refund_amount
from {{ ref('purchases_clean') }} p
left join {{ ref('customers_clean') }} c on p.user_id=c.user_id
left join {{ ref('products_clean') }} pr on p.product_id=pr.product_id
left join {{ ref('payments_clean') }} pay on p.purchase_id=pay.purchase_id
left join {{ ref('returns_clean') }} r on p.purchase_id=r.purchase_id
left join {{ ref('refunds_clean') }} rf on p.purchase_id=rf.purchase_id
