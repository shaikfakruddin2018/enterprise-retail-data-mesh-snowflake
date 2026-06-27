{{ config(materialized='table', database='PRODUCT_DOMAIN_DB', schema='GOLD', alias='PRODUCT_PERFORMANCE') }}
select pr.product_id, pr.product_name, pr.category, pr.subcategory, pr.brand, count(distinct pu.purchase_id) purchase_count,
       coalesce(sum(pu.quantity),0) units_sold, coalesce(sum(pu.total_amount),0) revenue, avg(rv.rating) avg_rating,
       count(distinct rv.review_id) review_count, count(distinct r.return_id) return_count,
       count(distinct r.return_id)/nullif(count(distinct pu.purchase_id),0) return_rate,
       case when coalesce(sum(pu.total_amount),0)>=10000 then 'top_performer' when coalesce(sum(pu.total_amount),0)>=3000 then 'mid_performer' else 'low_performer' end performance_segment
from {{ ref('products_clean') }} pr
left join {{ ref('purchases_clean') }} pu on pr.product_id=pu.product_id
left join {{ ref('reviews_clean') }} rv on pr.product_id=rv.product_id
left join {{ ref('returns_clean') }} r on pr.product_id=r.product_id
group by pr.product_id,pr.product_name,pr.category,pr.subcategory,pr.brand
