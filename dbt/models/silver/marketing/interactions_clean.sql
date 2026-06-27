{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='SILVER', alias='INTERACTIONS_CLEAN') }}
select trim(interaction_id) interaction_id, trim(user_id) user_id, trim(product_id) product_id, trim(session_id) session_id, lower(trim(interaction_type)) interaction_type, try_to_timestamp_ntz(timestamp) interaction_ts, try_to_number(dwell_time_ms) dwell_time_ms, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_marketing__interactions') }}
qualify row_number() over (partition by interaction_id order by load_timestamp desc)=1
