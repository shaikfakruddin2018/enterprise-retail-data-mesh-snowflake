{{ config(materialized='table', database='CUSTOMER_DOMAIN_DB', schema='SILVER', alias='CUSTOMERS_CLEAN') }}
select trim(user_id) as user_id, try_to_number(age) as age, initcap(trim(gender)) as gender, upper(trim(country)) as country, initcap(trim(city)) as city, try_to_date(signup_date,'DD-MM-YYYY') as signup_date, lower(trim(income_level)) as income_level, initcap(trim(preferred_category)) as preferred_category, lower(trim(loyalty_tier)) as loyalty_tier, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_customer__users') }}
qualify row_number() over (partition by user_id order by load_timestamp desc)=1
