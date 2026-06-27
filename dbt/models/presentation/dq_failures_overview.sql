{{ config(materialized='view', database='ANALYTICS_DB', schema='PRESENTATION', alias='DQ_FAILURES_OVERVIEW') }}
select * from values
  ('not_null:customers_clean.user_id','Customer','Critical',0,'user_id must not be null'),
  ('unique:customers_clean.user_id','Customer','Critical',0,'user_id must be unique'),
  ('accepted_range:customers_clean.age','Customer','Medium',0,'age between 13 and 100'),
  ('not_null:products_clean.product_id','Product','Critical',0,'product_id must not be null'),
  ('unique:products_clean.product_id','Product','Critical',0,'product_id must be unique'),
  ('accepted_range:products_clean.price','Product','High',0,'price >= 0'),
  ('relationships:purchases_clean.user_id','Sales','High',0,'fk to customers_clean.user_id'),
  ('relationships:purchases_clean.product_id','Sales','High',0,'fk to products_clean.product_id'),
  ('accepted_range:purchases_clean.quantity','Sales','Medium',0,'quantity >= 1'),
  ('relationships:sessions_clean.user_id','Marketing','Medium',0,'fk to customers_clean.user_id')
  as t(check_name, domain, severity, failed_records, rule)
