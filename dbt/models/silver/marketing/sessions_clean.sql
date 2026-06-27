{{ config(materialized='table', database='MARKETING_DOMAIN_DB', schema='SILVER', alias='SESSIONS_CLEAN') }}
select trim(session_id) session_id, trim(user_id) user_id, try_to_timestamp_ntz(start_time) start_time, lower(trim(device_type)) device_type, lower(trim(referrer_source)) referrer_source, try_to_boolean(is_converted) is_converted, load_timestamp, source_file, load_date, domain_name
from {{ ref('stg_marketing__sessions') }}
qualify row_number() over (partition by session_id order by load_timestamp desc)=1
