{{ config(materialized='table', database='PRODUCT_DOMAIN_DB', schema='GOLD', alias='SUPPLIER_PERFORMANCE') }}
select s.supplier_id, s.supplier_name, s.brand, s.primary_category, s.country, s.city, s.supplier_status, s.lead_time_days, s.quality_score,
       count(distinct p.product_id) supplied_product_count, coalesce(sum(pu.total_amount),0) supplier_brand_revenue, coalesce(sum(pu.quantity),0) supplier_brand_units_sold, avg(rv.rating) supplier_brand_avg_rating
from {{ ref('suppliers_clean') }} s
left join {{ ref('products_clean') }} p on s.brand=p.brand
left join {{ ref('purchases_clean') }} pu on p.product_id=pu.product_id
left join {{ ref('reviews_clean') }} rv on p.product_id=rv.product_id
group by s.supplier_id,s.supplier_name,s.brand,s.primary_category,s.country,s.city,s.supplier_status,s.lead_time_days,s.quality_score
