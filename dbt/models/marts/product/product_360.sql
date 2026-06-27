{{ config(materialized='table', database='PRODUCT_DOMAIN_DB', schema='GOLD', alias='PRODUCT_360') }}
select pr.product_id, pr.product_name, pr.category, pr.subcategory, pr.brand, pr.price, pr.rating_avg, pr.review_count, pr.stock_quantity, pr.date_added,
       count(distinct pu.purchase_id) total_purchases, coalesce(sum(pu.quantity),0) total_units_sold, coalesce(sum(pu.total_amount),0) total_revenue,
       avg(rv.rating) actual_avg_review_rating, count(distinct rv.review_id) total_reviews,
       coalesce(sum(inv.stock_on_hand),0) total_stock_on_hand, coalesce(sum(inv.reserved_quantity),0) total_reserved_quantity
from {{ ref('products_clean') }} pr
left join {{ ref('purchases_clean') }} pu on pr.product_id=pu.product_id
left join {{ ref('reviews_clean') }} rv on pr.product_id=rv.product_id
left join {{ ref('inventory_clean') }} inv on pr.product_id=inv.product_id
group by pr.product_id,pr.product_name,pr.category,pr.subcategory,pr.brand,pr.price,pr.rating_avg,pr.review_count,pr.stock_quantity,pr.date_added
