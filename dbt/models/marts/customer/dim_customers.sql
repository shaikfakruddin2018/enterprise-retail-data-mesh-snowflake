{{ config(materialized='table', database='CUSTOMER_DOMAIN_DB', schema='GOLD', alias='DIM_CUSTOMERS') }}
select user_id, age, gender, country, city, signup_date, income_level, preferred_category, loyalty_tier
from {{ ref('customers_clean') }}
