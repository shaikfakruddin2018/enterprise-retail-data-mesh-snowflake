-- 1. Create warehouse
CREATE OR REPLACE WAREHOUSE WH_DATAMESH_XS
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

-- 2. Create database
CREATE OR REPLACE DATABASE DATAMESH_DB;

-- 3. Create schemas
CREATE OR REPLACE SCHEMA DATAMESH_DB.RAW_CUSTOMER;
CREATE OR REPLACE SCHEMA DATAMESH_DB.RAW_PRODUCT;
CREATE OR REPLACE SCHEMA DATAMESH_DB.RAW_SALES;
CREATE OR REPLACE SCHEMA DATAMESH_DB.RAW_INVENTORY;
CREATE OR REPLACE SCHEMA DATAMESH_DB.RAW_MARKETING;

CREATE OR REPLACE FILE FORMAT DATAMESH_DB.PUBLIC.CSV_FORMAT
TYPE = CSV
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
NULL_IF = ('NULL', 'null', '')
EMPTY_FIELD_AS_NULL = TRUE;

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION S3_DATAMESH_INT
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::858650445839:role/snowflake-datamesh-role'
STORAGE_ALLOWED_LOCATIONS = ('s3://enpal-ops-copilot-shaik/Raw_Datamesh/');

DESC INTEGRATION S3_DATAMESH_INT;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;
USE DATABASE DATAMESH_DB;
USE SCHEMA PUBLIC;

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
TYPE = CSV
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
NULL_IF = ('NULL', 'null', '')
EMPTY_FIELD_AS_NULL = TRUE
TRIM_SPACE = TRUE;

CREATE OR REPLACE STAGE DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH
URL = 's3://enpal-ops-copilot-shaik/Raw_Datamesh/'
STORAGE_INTEGRATION = S3_DATAMESH_INT
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT;

LIST @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH;

LIST @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH;

CREATE OR REPLACE TABLE DATAMESH_DB.RAW_SALES.PURCHASES_RAW (
  -- columns based on purchases.csv
);

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;
USE DATABASE DATAMESH_DB;

-- =========================
-- RAW CUSTOMER
-- =========================

CREATE OR REPLACE TABLE RAW_CUSTOMER.USERS_RAW (
    user_id VARCHAR,
    age NUMBER,
    gender VARCHAR,
    country VARCHAR,
    city VARCHAR,
    signup_date VARCHAR,
    income_level VARCHAR,
    preferred_category VARCHAR,
    loyalty_tier VARCHAR
);

CREATE OR REPLACE TABLE RAW_CUSTOMER.SUPPORT_TICKETS_RAW (
    ticket_id VARCHAR,
    user_id VARCHAR,
    order_id VARCHAR,
    product_id VARCHAR,
    created_ts VARCHAR,
    closed_ts VARCHAR,
    ticket_channel VARCHAR,
    ticket_category VARCHAR,
    priority VARCHAR,
    ticket_status VARCHAR,
    subject VARCHAR,
    satisfaction_score NUMBER
);

-- =========================
-- RAW PRODUCT
-- =========================

CREATE OR REPLACE TABLE RAW_PRODUCT.PRODUCTS_RAW (
    product_id VARCHAR,
    product_name VARCHAR,
    product_description VARCHAR,
    category VARCHAR,
    subcategory VARCHAR,
    brand VARCHAR,
    price NUMBER(18,2),
    rating_avg NUMBER(18,2),
    review_count NUMBER,
    stock_quantity NUMBER,
    date_added VARCHAR
);

CREATE OR REPLACE TABLE RAW_PRODUCT.REVIEWS_RAW (
    review_id VARCHAR,
    user_id VARCHAR,
    product_id VARCHAR,
    purchase_id VARCHAR,
    rating NUMBER,
    title VARCHAR,
    review_text VARCHAR,
    review_date VARCHAR
);

CREATE OR REPLACE TABLE RAW_PRODUCT.SUPPLIERS_RAW (
    supplier_id VARCHAR,
    supplier_name VARCHAR,
    brand VARCHAR,
    primary_category VARCHAR,
    country VARCHAR,
    city VARCHAR,
    supplier_status VARCHAR,
    lead_time_days NUMBER,
    quality_score NUMBER(18,2),
    created_at VARCHAR
);

-- =========================
-- RAW SALES
-- =========================

CREATE OR REPLACE TABLE RAW_SALES.PURCHASES_RAW (
    purchase_id VARCHAR,
    order_id VARCHAR,
    user_id VARCHAR,
    product_id VARCHAR,
    session_id VARCHAR,
    interaction_id VARCHAR,
    quantity NUMBER,
    unit_price NUMBER(18,2),
    total_amount NUMBER(18,2),
    order_date VARCHAR
);

CREATE OR REPLACE TABLE RAW_SALES.PAYMENTS_RAW (
    payment_id VARCHAR,
    order_id VARCHAR,
    purchase_id VARCHAR,
    user_id VARCHAR,
    payment_ts VARCHAR,
    payment_method VARCHAR,
    payment_status VARCHAR,
    amount NUMBER(18,2),
    currency_code VARCHAR,
    transaction_reference VARCHAR,
    failure_reason VARCHAR,
    fraud_score NUMBER(18,2)
);

CREATE OR REPLACE TABLE RAW_SALES.RETURNS_RAW (
    return_id VARCHAR,
    order_id VARCHAR,
    purchase_id VARCHAR,
    shipment_id VARCHAR,
    user_id VARCHAR,
    product_id VARCHAR,
    return_ts VARCHAR,
    return_reason VARCHAR,
    return_status VARCHAR,
    quantity_returned NUMBER,
    condition_received VARCHAR
);

CREATE OR REPLACE TABLE RAW_SALES.REFUNDS_RAW (
    refund_id VARCHAR,
    return_id VARCHAR,
    order_id VARCHAR,
    purchase_id VARCHAR,
    user_id VARCHAR,
    refund_ts VARCHAR,
    refund_status VARCHAR,
    refund_method VARCHAR,
    refund_amount NUMBER(18,2),
    currency_code VARCHAR,
    refund_reason VARCHAR
);

-- =========================
-- RAW INVENTORY
-- =========================

CREATE OR REPLACE TABLE RAW_INVENTORY.INVENTORY_RAW (
    inventory_id VARCHAR,
    product_id VARCHAR,
    warehouse_id VARCHAR,
    stock_on_hand NUMBER,
    reserved_quantity NUMBER,
    reorder_point NUMBER,
    reorder_quantity NUMBER,
    inventory_status VARCHAR,
    last_stocktake_date VARCHAR
);

CREATE OR REPLACE TABLE RAW_INVENTORY.WAREHOUSES_RAW (
    warehouse_id VARCHAR,
    warehouse_name VARCHAR,
    country VARCHAR,
    state VARCHAR,
    city VARCHAR,
    postal_code VARCHAR,
    timezone VARCHAR,
    is_active BOOLEAN,
    opened_date VARCHAR
);

CREATE OR REPLACE TABLE RAW_INVENTORY.SHIPMENTS_RAW (
    shipment_id VARCHAR,
    order_id VARCHAR,
    purchase_id VARCHAR,
    user_id VARCHAR,
    warehouse_id VARCHAR,
    carrier VARCHAR,
    tracking_number VARCHAR,
    shipment_status VARCHAR,
    shipped_ts VARCHAR,
    promised_delivery_ts VARCHAR,
    delivered_ts VARCHAR,
    is_late BOOLEAN,
    shipping_cost NUMBER(18,2)
);

-- =========================
-- RAW MARKETING
-- =========================

CREATE OR REPLACE TABLE RAW_MARKETING.SESSIONS_RAW (
    session_id VARCHAR,
    user_id VARCHAR,
    start_time VARCHAR,
    device_type VARCHAR,
    referrer_source VARCHAR,
    is_converted BOOLEAN
);

CREATE OR REPLACE TABLE RAW_MARKETING.INTERACTIONS_RAW (
    interaction_id VARCHAR,
    user_id VARCHAR,
    product_id VARCHAR,
    session_id VARCHAR,
    interaction_type VARCHAR,
    timestamp VARCHAR,
    dwell_time_ms NUMBER
);

CREATE OR REPLACE TABLE RAW_MARKETING.CAMPAIGNS_RAW (
    campaign_id VARCHAR,
    campaign_name VARCHAR,
    channel VARCHAR,
    objective VARCHAR,
    start_date VARCHAR,
    end_date VARCHAR,
    budget_amount NUMBER(18,2),
    currency_code VARCHAR,
    target_country VARCHAR,
    campaign_status VARCHAR
);

CREATE OR REPLACE TABLE RAW_MARKETING.CAMPAIGN_PERFORMANCE_RAW (
    campaign_id VARCHAR,
    sessions NUMBER,
    conversions NUMBER,
    spend_amount NUMBER(18,2),
    impressions NUMBER,
    clicks NUMBER
);

-- =========================
-- COPY INTO LOADS
-- =========================

COPY INTO RAW_CUSTOMER.USERS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/users.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_CUSTOMER.SUPPORT_TICKETS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/support_tickets.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_PRODUCT.PRODUCTS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/products.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_PRODUCT.REVIEWS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/reviews.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_PRODUCT.SUPPLIERS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/suppliers.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_SALES.PURCHASES_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/purchases.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_SALES.PAYMENTS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/payments.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_SALES.RETURNS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/returns.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_SALES.REFUNDS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/refunds.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_INVENTORY.INVENTORY_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/inventory.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_INVENTORY.WAREHOUSES_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/warehouses.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_INVENTORY.SHIPMENTS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/shipments.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_MARKETING.SESSIONS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/sessions.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_MARKETING.INTERACTIONS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/interactions.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_MARKETING.CAMPAIGNS_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/campaigns.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

COPY INTO RAW_MARKETING.CAMPAIGN_PERFORMANCE_RAW
FROM @DATAMESH_DB.PUBLIC.STG_RAW_DATAMESH/campaign_performance.csv
FILE_FORMAT = DATAMESH_DB.PUBLIC.CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- =========================
-- VALIDATION
-- =========================
SELECT 'USERS_RAW' AS table_name, COUNT(*) AS row_count
FROM RAW_CUSTOMER.USERS_RAW

UNION ALL
SELECT 'SUPPORT_TICKETS_RAW', COUNT(*)
FROM RAW_CUSTOMER.SUPPORT_TICKETS_RAW

UNION ALL
SELECT 'PRODUCTS_RAW', COUNT(*)
FROM RAW_PRODUCT.PRODUCTS_RAW

UNION ALL
SELECT 'REVIEWS_RAW', COUNT(*)
FROM RAW_PRODUCT.REVIEWS_RAW

UNION ALL
SELECT 'SUPPLIERS_RAW', COUNT(*)
FROM RAW_PRODUCT.SUPPLIERS_RAW

UNION ALL
SELECT 'PURCHASES_RAW', COUNT(*)
FROM RAW_SALES.PURCHASES_RAW

UNION ALL
SELECT 'PAYMENTS_RAW', COUNT(*)
FROM RAW_SALES.PAYMENTS_RAW

UNION ALL
SELECT 'RETURNS_RAW', COUNT(*)
FROM RAW_SALES.RETURNS_RAW

UNION ALL
SELECT 'REFUNDS_RAW', COUNT(*)
FROM RAW_SALES.REFUNDS_RAW

UNION ALL
SELECT 'INVENTORY_RAW', COUNT(*)
FROM RAW_INVENTORY.INVENTORY_RAW

UNION ALL
SELECT 'WAREHOUSES_RAW', COUNT(*)
FROM RAW_INVENTORY.WAREHOUSES_RAW

UNION ALL
SELECT 'SHIPMENTS_RAW', COUNT(*)
FROM RAW_INVENTORY.SHIPMENTS_RAW

UNION ALL
SELECT 'SESSIONS_RAW', COUNT(*)
FROM RAW_MARKETING.SESSIONS_RAW

UNION ALL
SELECT 'INTERACTIONS_RAW', COUNT(*)
FROM RAW_MARKETING.INTERACTIONS_RAW

UNION ALL
SELECT 'CAMPAIGNS_RAW', COUNT(*)
FROM RAW_MARKETING.CAMPAIGNS_RAW

UNION ALL
SELECT 'CAMPAIGN_PERFORMANCE_RAW', COUNT(*)
FROM RAW_MARKETING.CAMPAIGN_PERFORMANCE_RAW

ORDER BY table_name;

CREATE OR REPLACE DATABASE CUSTOMER_DOMAIN_DB;
CREATE OR REPLACE SCHEMA CUSTOMER_DOMAIN_DB.RAW;
CREATE OR REPLACE SCHEMA CUSTOMER_DOMAIN_DB.BRONZE;
CREATE OR REPLACE SCHEMA CUSTOMER_DOMAIN_DB.SILVER;
CREATE OR REPLACE SCHEMA CUSTOMER_DOMAIN_DB.GOLD;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

CREATE DATABASE IF NOT EXISTS CUSTOMER_DOMAIN_DB;
CREATE DATABASE IF NOT EXISTS PRODUCT_DOMAIN_DB;
CREATE DATABASE IF NOT EXISTS SALES_DOMAIN_DB;
CREATE DATABASE IF NOT EXISTS INVENTORY_DOMAIN_DB;
CREATE DATABASE IF NOT EXISTS MARKETING_DOMAIN_DB;

CREATE SCHEMA IF NOT EXISTS CUSTOMER_DOMAIN_DB.RAW;
CREATE SCHEMA IF NOT EXISTS CUSTOMER_DOMAIN_DB.BRONZE;
CREATE SCHEMA IF NOT EXISTS CUSTOMER_DOMAIN_DB.SILVER;
CREATE SCHEMA IF NOT EXISTS CUSTOMER_DOMAIN_DB.GOLD;

CREATE SCHEMA IF NOT EXISTS PRODUCT_DOMAIN_DB.RAW;
CREATE SCHEMA IF NOT EXISTS PRODUCT_DOMAIN_DB.BRONZE;
CREATE SCHEMA IF NOT EXISTS PRODUCT_DOMAIN_DB.SILVER;
CREATE SCHEMA IF NOT EXISTS PRODUCT_DOMAIN_DB.GOLD;

CREATE SCHEMA IF NOT EXISTS SALES_DOMAIN_DB.RAW;
CREATE SCHEMA IF NOT EXISTS SALES_DOMAIN_DB.BRONZE;
CREATE SCHEMA IF NOT EXISTS SALES_DOMAIN_DB.SILVER;
CREATE SCHEMA IF NOT EXISTS SALES_DOMAIN_DB.GOLD;

CREATE SCHEMA IF NOT EXISTS INVENTORY_DOMAIN_DB.RAW;
CREATE SCHEMA IF NOT EXISTS INVENTORY_DOMAIN_DB.BRONZE;
CREATE SCHEMA IF NOT EXISTS INVENTORY_DOMAIN_DB.SILVER;
CREATE SCHEMA IF NOT EXISTS INVENTORY_DOMAIN_DB.GOLD;

CREATE SCHEMA IF NOT EXISTS MARKETING_DOMAIN_DB.RAW;
CREATE SCHEMA IF NOT EXISTS MARKETING_DOMAIN_DB.BRONZE;
CREATE SCHEMA IF NOT EXISTS MARKETING_DOMAIN_DB.SILVER;
CREATE SCHEMA IF NOT EXISTS MARKETING_DOMAIN_DB.GOLD;

CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.RAW.USERS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_CUSTOMER.USERS_RAW;

CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.BRONZE.USERS_BRONZE AS
SELECT
    *,
    CURRENT_TIMESTAMP() AS load_timestamp,
    'users.csv' AS source_file,
    CURRENT_DATE() AS load_date
FROM CUSTOMER_DOMAIN_DB.RAW.USERS_RAW;


USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

-- CUSTOMER
CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.RAW.USERS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_CUSTOMER.USERS_RAW;

CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.RAW.SUPPORT_TICKETS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_CUSTOMER.SUPPORT_TICKETS_RAW;

-- PRODUCT
CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.RAW.PRODUCTS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_PRODUCT.PRODUCTS_RAW;

CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.RAW.REVIEWS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_PRODUCT.REVIEWS_RAW;

CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.RAW.SUPPLIERS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_PRODUCT.SUPPLIERS_RAW;

-- SALES
CREATE OR REPLACE TABLE SALES_DOMAIN_DB.RAW.PURCHASES_RAW AS
SELECT * FROM DATAMESH_DB.RAW_SALES.PURCHASES_RAW;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.RAW.PAYMENTS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_SALES.PAYMENTS_RAW;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.RAW.RETURNS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_SALES.RETURNS_RAW;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.RAW.REFUNDS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_SALES.REFUNDS_RAW;

-- INVENTORY
CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.RAW.INVENTORY_RAW AS
SELECT * FROM DATAMESH_DB.RAW_INVENTORY.INVENTORY_RAW;

CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.RAW.WAREHOUSES_RAW AS
SELECT * FROM DATAMESH_DB.RAW_INVENTORY.WAREHOUSES_RAW;

CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.RAW.SHIPMENTS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_INVENTORY.SHIPMENTS_RAW;

-- MARKETING
CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.RAW.SESSIONS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_MARKETING.SESSIONS_RAW;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.RAW.INTERACTIONS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_MARKETING.INTERACTIONS_RAW;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.RAW.CAMPAIGNS_RAW AS
SELECT * FROM DATAMESH_DB.RAW_MARKETING.CAMPAIGNS_RAW;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.RAW.CAMPAIGN_PERFORMANCE_RAW AS
SELECT * FROM DATAMESH_DB.RAW_MARKETING.CAMPAIGN_PERFORMANCE_RAW;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

-- CUSTOMER DOMAIN
CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.BRONZE.USERS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'users.csv' AS source_file, CURRENT_DATE() AS load_date, 'customer' AS domain_name
FROM CUSTOMER_DOMAIN_DB.RAW.USERS_RAW;

CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.BRONZE.SUPPORT_TICKETS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'support_tickets.csv' AS source_file, CURRENT_DATE() AS load_date, 'customer' AS domain_name
FROM CUSTOMER_DOMAIN_DB.RAW.SUPPORT_TICKETS_RAW;

-- PRODUCT DOMAIN
CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.BRONZE.PRODUCTS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'products.csv' AS source_file, CURRENT_DATE() AS load_date, 'product' AS domain_name
FROM PRODUCT_DOMAIN_DB.RAW.PRODUCTS_RAW;

CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.BRONZE.REVIEWS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'reviews.csv' AS source_file, CURRENT_DATE() AS load_date, 'product' AS domain_name
FROM PRODUCT_DOMAIN_DB.RAW.REVIEWS_RAW;

CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.BRONZE.SUPPLIERS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'suppliers.csv' AS source_file, CURRENT_DATE() AS load_date, 'product' AS domain_name
FROM PRODUCT_DOMAIN_DB.RAW.SUPPLIERS_RAW;

-- SALES DOMAIN
CREATE OR REPLACE TABLE SALES_DOMAIN_DB.BRONZE.PURCHASES_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'purchases.csv' AS source_file, CURRENT_DATE() AS load_date, 'sales' AS domain_name
FROM SALES_DOMAIN_DB.RAW.PURCHASES_RAW;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.BRONZE.PAYMENTS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'payments.csv' AS source_file, CURRENT_DATE() AS load_date, 'sales' AS domain_name
FROM SALES_DOMAIN_DB.RAW.PAYMENTS_RAW;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.BRONZE.RETURNS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'returns.csv' AS source_file, CURRENT_DATE() AS load_date, 'sales' AS domain_name
FROM SALES_DOMAIN_DB.RAW.RETURNS_RAW;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.BRONZE.REFUNDS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'refunds.csv' AS source_file, CURRENT_DATE() AS load_date, 'sales' AS domain_name
FROM SALES_DOMAIN_DB.RAW.REFUNDS_RAW;

-- INVENTORY DOMAIN
CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.BRONZE.INVENTORY_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'inventory.csv' AS source_file, CURRENT_DATE() AS load_date, 'inventory' AS domain_name
FROM INVENTORY_DOMAIN_DB.RAW.INVENTORY_RAW;

CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.BRONZE.WAREHOUSES_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'warehouses.csv' AS source_file, CURRENT_DATE() AS load_date, 'inventory' AS domain_name
FROM INVENTORY_DOMAIN_DB.RAW.WAREHOUSES_RAW;

CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.BRONZE.SHIPMENTS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'shipments.csv' AS source_file, CURRENT_DATE() AS load_date, 'inventory' AS domain_name
FROM INVENTORY_DOMAIN_DB.RAW.SHIPMENTS_RAW;

-- MARKETING DOMAIN
CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.BRONZE.SESSIONS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'sessions.csv' AS source_file, CURRENT_DATE() AS load_date, 'marketing' AS domain_name
FROM MARKETING_DOMAIN_DB.RAW.SESSIONS_RAW;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.BRONZE.INTERACTIONS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'interactions.csv' AS source_file, CURRENT_DATE() AS load_date, 'marketing' AS domain_name
FROM MARKETING_DOMAIN_DB.RAW.INTERACTIONS_RAW;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.BRONZE.CAMPAIGNS_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'campaigns.csv' AS source_file, CURRENT_DATE() AS load_date, 'marketing' AS domain_name
FROM MARKETING_DOMAIN_DB.RAW.CAMPAIGNS_RAW;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.BRONZE.CAMPAIGN_PERFORMANCE_BRONZE AS
SELECT *, CURRENT_TIMESTAMP() AS load_timestamp, 'campaign_performance.csv' AS source_file, CURRENT_DATE() AS load_date, 'marketing' AS domain_name
FROM MARKETING_DOMAIN_DB.RAW.CAMPAIGN_PERFORMANCE_RAW;

-- VALIDATION
SELECT 'CUSTOMER.USERS_BRONZE' AS table_name, COUNT(*) AS row_count FROM CUSTOMER_DOMAIN_DB.BRONZE.USERS_BRONZE
UNION ALL SELECT 'CUSTOMER.SUPPORT_TICKETS_BRONZE', COUNT(*) FROM CUSTOMER_DOMAIN_DB.BRONZE.SUPPORT_TICKETS_BRONZE
UNION ALL SELECT 'PRODUCT.PRODUCTS_BRONZE', COUNT(*) FROM PRODUCT_DOMAIN_DB.BRONZE.PRODUCTS_BRONZE
UNION ALL SELECT 'PRODUCT.REVIEWS_BRONZE', COUNT(*) FROM PRODUCT_DOMAIN_DB.BRONZE.REVIEWS_BRONZE
UNION ALL SELECT 'PRODUCT.SUPPLIERS_BRONZE', COUNT(*) FROM PRODUCT_DOMAIN_DB.BRONZE.SUPPLIERS_BRONZE
UNION ALL SELECT 'SALES.PURCHASES_BRONZE', COUNT(*) FROM SALES_DOMAIN_DB.BRONZE.PURCHASES_BRONZE
UNION ALL SELECT 'SALES.PAYMENTS_BRONZE', COUNT(*) FROM SALES_DOMAIN_DB.BRONZE.PAYMENTS_BRONZE
UNION ALL SELECT 'SALES.RETURNS_BRONZE', COUNT(*) FROM SALES_DOMAIN_DB.BRONZE.RETURNS_BRONZE
UNION ALL SELECT 'SALES.REFUNDS_BRONZE', COUNT(*) FROM SALES_DOMAIN_DB.BRONZE.REFUNDS_BRONZE
UNION ALL SELECT 'INVENTORY.INVENTORY_BRONZE', COUNT(*) FROM INVENTORY_DOMAIN_DB.BRONZE.INVENTORY_BRONZE
UNION ALL SELECT 'INVENTORY.WAREHOUSES_BRONZE', COUNT(*) FROM INVENTORY_DOMAIN_DB.BRONZE.WAREHOUSES_BRONZE
UNION ALL SELECT 'INVENTORY.SHIPMENTS_BRONZE', COUNT(*) FROM INVENTORY_DOMAIN_DB.BRONZE.SHIPMENTS_BRONZE
UNION ALL SELECT 'MARKETING.SESSIONS_BRONZE', COUNT(*) FROM MARKETING_DOMAIN_DB.BRONZE.SESSIONS_BRONZE
UNION ALL SELECT 'MARKETING.INTERACTIONS_BRONZE', COUNT(*) FROM MARKETING_DOMAIN_DB.BRONZE.INTERACTIONS_BRONZE
UNION ALL SELECT 'MARKETING.CAMPAIGNS_BRONZE', COUNT(*) FROM MARKETING_DOMAIN_DB.BRONZE.CAMPAIGNS_BRONZE
UNION ALL SELECT 'MARKETING.CAMPAIGN_PERFORMANCE_BRONZE', COUNT(*) FROM MARKETING_DOMAIN_DB.BRONZE.CAMPAIGN_PERFORMANCE_BRONZE
ORDER BY table_name;


USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN AS
SELECT
    TRIM(user_id) AS user_id,
    TRY_TO_NUMBER(age) AS age,
    INITCAP(TRIM(gender)) AS gender,
    UPPER(TRIM(country)) AS country,
    INITCAP(TRIM(city)) AS city,
    TRY_TO_DATE(signup_date, 'DD-MM-YYYY') AS signup_date,
    LOWER(TRIM(income_level)) AS income_level,
    INITCAP(TRIM(preferred_category)) AS preferred_category,
    LOWER(TRIM(loyalty_tier)) AS loyalty_tier,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM CUSTOMER_DOMAIN_DB.BRONZE.USERS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN AS
SELECT
    TRIM(product_id) AS product_id,
    TRIM(product_name) AS product_name,
    TRIM(product_description) AS product_description,
    INITCAP(TRIM(category)) AS category,
    INITCAP(TRIM(subcategory)) AS subcategory,
    INITCAP(TRIM(brand)) AS brand,
    TRY_TO_DECIMAL(price, 18, 2) AS price,
    TRY_TO_DECIMAL(rating_avg, 18, 2) AS rating_avg,
    TRY_TO_NUMBER(review_count) AS review_count,
    TRY_TO_NUMBER(stock_quantity) AS stock_quantity,
    TRY_TO_DATE(date_added, 'DD-MM-YYYY') AS date_added,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM PRODUCT_DOMAIN_DB.BRONZE.PRODUCTS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY product_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN AS
SELECT
    TRIM(purchase_id) AS purchase_id,
    TRIM(order_id) AS order_id,
    TRIM(user_id) AS user_id,
    TRIM(product_id) AS product_id,
    TRIM(session_id) AS session_id,
    TRIM(interaction_id) AS interaction_id,
    TRY_TO_NUMBER(quantity) AS quantity,
    TRY_TO_DECIMAL(unit_price, 18, 2) AS unit_price,
    TRY_TO_DECIMAL(total_amount, 18, 2) AS total_amount,
    TRY_TO_DATE(order_date, 'DD-MM-YYYY') AS order_date,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM SALES_DOMAIN_DB.BRONZE.PURCHASES_BRONZE
WHERE TRY_TO_NUMBER(quantity) > 0
  AND TRY_TO_DECIMAL(total_amount, 18, 2) >= 0
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY purchase_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN AS
SELECT
    TRIM(session_id) AS session_id,
    TRIM(user_id) AS user_id,
    TRY_TO_TIMESTAMP_NTZ(start_time) AS start_time,
    LOWER(TRIM(device_type)) AS device_type,
    LOWER(TRIM(referrer_source)) AS referrer_source,
    TRY_TO_BOOLEAN(is_converted) AS is_converted,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM MARKETING_DOMAIN_DB.BRONZE.SESSIONS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY session_id
    ORDER BY load_timestamp DESC
) = 1;

SELECT 'CUSTOMERS_CLEAN' AS table_name, COUNT(*) AS row_count FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
UNION ALL
SELECT 'PRODUCTS_CLEAN', COUNT(*) FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN
UNION ALL
SELECT 'PURCHASES_CLEAN', COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN
UNION ALL
SELECT 'SESSIONS_CLEAN', COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

-- CUSTOMER
CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.SILVER.SUPPORT_TICKETS_CLEAN AS
SELECT
    TRIM(ticket_id) AS ticket_id,
    TRIM(user_id) AS user_id,
    TRIM(order_id) AS order_id,
    TRIM(product_id) AS product_id,
    TRY_TO_TIMESTAMP_NTZ(created_ts) AS created_ts,
    TRY_TO_TIMESTAMP_NTZ(closed_ts) AS closed_ts,
    LOWER(TRIM(ticket_channel)) AS ticket_channel,
    LOWER(TRIM(ticket_category)) AS ticket_category,
    LOWER(TRIM(priority)) AS priority,
    LOWER(TRIM(ticket_status)) AS ticket_status,
    TRIM(subject) AS subject,
    TRY_TO_NUMBER(satisfaction_score) AS satisfaction_score,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM CUSTOMER_DOMAIN_DB.BRONZE.SUPPORT_TICKETS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ticket_id
    ORDER BY load_timestamp DESC
) = 1;

-- PRODUCT
CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.SILVER.REVIEWS_CLEAN AS
SELECT
    TRIM(review_id) AS review_id,
    TRIM(user_id) AS user_id,
    TRIM(product_id) AS product_id,
    TRIM(purchase_id) AS purchase_id,
    TRY_TO_NUMBER(rating) AS rating,
    TRIM(title) AS title,
    TRIM(review_text) AS review_text,
    TRY_TO_DATE(review_date, 'DD-MM-YYYY') AS review_date,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM PRODUCT_DOMAIN_DB.BRONZE.REVIEWS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY review_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.SILVER.SUPPLIERS_CLEAN AS
SELECT
    TRIM(supplier_id) AS supplier_id,
    TRIM(supplier_name) AS supplier_name,
    INITCAP(TRIM(brand)) AS brand,
    INITCAP(TRIM(primary_category)) AS primary_category,
    UPPER(TRIM(country)) AS country,
    INITCAP(TRIM(city)) AS city,
    LOWER(TRIM(supplier_status)) AS supplier_status,
    TRY_TO_NUMBER(lead_time_days) AS lead_time_days,
    TRY_TO_DECIMAL(quality_score, 18, 2) AS quality_score,
    TRY_TO_DATE(created_at, 'DD-MM-YYYY') AS created_at,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM PRODUCT_DOMAIN_DB.BRONZE.SUPPLIERS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY supplier_id
    ORDER BY load_timestamp DESC
) = 1;

-- SALES
CREATE OR REPLACE TABLE SALES_DOMAIN_DB.SILVER.PAYMENTS_CLEAN AS
SELECT
    TRIM(payment_id) AS payment_id,
    TRIM(order_id) AS order_id,
    TRIM(purchase_id) AS purchase_id,
    TRIM(user_id) AS user_id,
    TRY_TO_TIMESTAMP_NTZ(payment_ts) AS payment_ts,
    LOWER(TRIM(payment_method)) AS payment_method,
    LOWER(TRIM(payment_status)) AS payment_status,
    TRY_TO_DECIMAL(amount, 18, 2) AS amount,
    UPPER(TRIM(currency_code)) AS currency_code,
    TRIM(transaction_reference) AS transaction_reference,
    NULLIF(LOWER(TRIM(failure_reason)), '') AS failure_reason,
    TRY_TO_DECIMAL(fraud_score, 18, 2) AS fraud_score,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM SALES_DOMAIN_DB.BRONZE.PAYMENTS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY payment_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.SILVER.RETURNS_CLEAN AS
SELECT
    TRIM(return_id) AS return_id,
    TRIM(order_id) AS order_id,
    TRIM(purchase_id) AS purchase_id,
    TRIM(shipment_id) AS shipment_id,
    TRIM(user_id) AS user_id,
    TRIM(product_id) AS product_id,
    TRY_TO_TIMESTAMP_NTZ(return_ts) AS return_ts,
    LOWER(TRIM(return_reason)) AS return_reason,
    LOWER(TRIM(return_status)) AS return_status,
    TRY_TO_NUMBER(quantity_returned) AS quantity_returned,
    LOWER(TRIM(condition_received)) AS condition_received,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM SALES_DOMAIN_DB.BRONZE.RETURNS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY return_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.SILVER.REFUNDS_CLEAN AS
SELECT
    TRIM(refund_id) AS refund_id,
    TRIM(return_id) AS return_id,
    TRIM(order_id) AS order_id,
    TRIM(purchase_id) AS purchase_id,
    TRIM(user_id) AS user_id,
    TRY_TO_TIMESTAMP_NTZ(refund_ts) AS refund_ts,
    LOWER(TRIM(refund_status)) AS refund_status,
    LOWER(TRIM(refund_method)) AS refund_method,
    TRY_TO_DECIMAL(refund_amount, 18, 2) AS refund_amount,
    UPPER(TRIM(currency_code)) AS currency_code,
    LOWER(TRIM(refund_reason)) AS refund_reason,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM SALES_DOMAIN_DB.BRONZE.REFUNDS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY refund_id
    ORDER BY load_timestamp DESC
) = 1;

-- INVENTORY
CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN AS
SELECT
    TRIM(inventory_id) AS inventory_id,
    TRIM(product_id) AS product_id,
    TRIM(warehouse_id) AS warehouse_id,
    TRY_TO_NUMBER(stock_on_hand) AS stock_on_hand,
    TRY_TO_NUMBER(reserved_quantity) AS reserved_quantity,
    TRY_TO_NUMBER(reorder_point) AS reorder_point,
    TRY_TO_NUMBER(reorder_quantity) AS reorder_quantity,
    LOWER(TRIM(inventory_status)) AS inventory_status,
    TRY_TO_DATE(last_stocktake_date, 'DD-MM-YYYY') AS last_stocktake_date,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM INVENTORY_DOMAIN_DB.BRONZE.INVENTORY_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY inventory_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.SILVER.WAREHOUSES_CLEAN AS
SELECT
    TRIM(warehouse_id) AS warehouse_id,
    TRIM(warehouse_name) AS warehouse_name,
    UPPER(TRIM(country)) AS country,
    UPPER(TRIM(state)) AS state,
    INITCAP(TRIM(city)) AS city,
    TRIM(postal_code) AS postal_code,
    TRIM(timezone) AS timezone,
    TRY_TO_BOOLEAN(is_active) AS is_active,
    TRY_TO_DATE(opened_date, 'DD-MM-YYYY') AS opened_date,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM INVENTORY_DOMAIN_DB.BRONZE.WAREHOUSES_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY warehouse_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.SILVER.SHIPMENTS_CLEAN AS
SELECT
    TRIM(shipment_id) AS shipment_id,
    TRIM(order_id) AS order_id,
    TRIM(purchase_id) AS purchase_id,
    TRIM(user_id) AS user_id,
    TRIM(warehouse_id) AS warehouse_id,
    TRIM(carrier) AS carrier,
    TRIM(tracking_number) AS tracking_number,
    LOWER(TRIM(shipment_status)) AS shipment_status,
    TRY_TO_TIMESTAMP_NTZ(shipped_ts) AS shipped_ts,
    TRY_TO_TIMESTAMP_NTZ(promised_delivery_ts) AS promised_delivery_ts,
    TRY_TO_TIMESTAMP_NTZ(delivered_ts) AS delivered_ts,
    TRY_TO_BOOLEAN(is_late) AS is_late,
    TRY_TO_DECIMAL(shipping_cost, 18, 2) AS shipping_cost,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM INVENTORY_DOMAIN_DB.BRONZE.SHIPMENTS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY shipment_id
    ORDER BY load_timestamp DESC
) = 1;

-- MARKETING
CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.SILVER.INTERACTIONS_CLEAN AS
SELECT
    TRIM(interaction_id) AS interaction_id,
    TRIM(user_id) AS user_id,
    TRIM(product_id) AS product_id,
    TRIM(session_id) AS session_id,
    LOWER(TRIM(interaction_type)) AS interaction_type,
    TRY_TO_TIMESTAMP_NTZ(timestamp) AS interaction_ts,
    TRY_TO_NUMBER(dwell_time_ms) AS dwell_time_ms,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM MARKETING_DOMAIN_DB.BRONZE.INTERACTIONS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY interaction_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.SILVER.CAMPAIGNS_CLEAN AS
SELECT
    TRIM(campaign_id) AS campaign_id,
    TRIM(campaign_name) AS campaign_name,
    LOWER(TRIM(channel)) AS channel,
    LOWER(TRIM(objective)) AS objective,
    TRY_TO_DATE(start_date, 'DD-MM-YYYY') AS start_date,
    TRY_TO_DATE(end_date, 'DD-MM-YYYY') AS end_date,
    TRY_TO_DECIMAL(budget_amount, 18, 2) AS budget_amount,
    UPPER(TRIM(currency_code)) AS currency_code,
    UPPER(TRIM(target_country)) AS target_country,
    LOWER(TRIM(campaign_status)) AS campaign_status,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM MARKETING_DOMAIN_DB.BRONZE.CAMPAIGNS_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY campaign_id
    ORDER BY load_timestamp DESC
) = 1;

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.SILVER.CAMPAIGN_PERFORMANCE_CLEAN AS
SELECT
    TRIM(campaign_id) AS campaign_id,
    TRY_TO_NUMBER(sessions) AS sessions,
    TRY_TO_NUMBER(conversions) AS conversions,
    TRY_TO_DECIMAL(spend_amount, 18, 2) AS spend_amount,
    TRY_TO_NUMBER(impressions) AS impressions,
    TRY_TO_NUMBER(clicks) AS clicks,
    load_timestamp,
    source_file,
    load_date,
    domain_name
FROM MARKETING_DOMAIN_DB.BRONZE.CAMPAIGN_PERFORMANCE_BRONZE
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY campaign_id
    ORDER BY load_timestamp DESC
) = 1;

-- VALIDATION
SELECT 'CUSTOMERS_CLEAN' AS table_name, COUNT(*) AS row_count FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
UNION ALL SELECT 'SUPPORT_TICKETS_CLEAN', COUNT(*) FROM CUSTOMER_DOMAIN_DB.SILVER.SUPPORT_TICKETS_CLEAN
UNION ALL SELECT 'PRODUCTS_CLEAN', COUNT(*) FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN
UNION ALL SELECT 'REVIEWS_CLEAN', COUNT(*) FROM PRODUCT_DOMAIN_DB.SILVER.REVIEWS_CLEAN
UNION ALL SELECT 'SUPPLIERS_CLEAN', COUNT(*) FROM PRODUCT_DOMAIN_DB.SILVER.SUPPLIERS_CLEAN
UNION ALL SELECT 'PURCHASES_CLEAN', COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN
UNION ALL SELECT 'PAYMENTS_CLEAN', COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PAYMENTS_CLEAN
UNION ALL SELECT 'RETURNS_CLEAN', COUNT(*) FROM SALES_DOMAIN_DB.SILVER.RETURNS_CLEAN
UNION ALL SELECT 'REFUNDS_CLEAN', COUNT(*) FROM SALES_DOMAIN_DB.SILVER.REFUNDS_CLEAN
UNION ALL SELECT 'INVENTORY_CLEAN', COUNT(*) FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN
UNION ALL SELECT 'WAREHOUSES_CLEAN', COUNT(*) FROM INVENTORY_DOMAIN_DB.SILVER.WAREHOUSES_CLEAN
UNION ALL SELECT 'SHIPMENTS_CLEAN', COUNT(*) FROM INVENTORY_DOMAIN_DB.SILVER.SHIPMENTS_CLEAN
UNION ALL SELECT 'SESSIONS_CLEAN', COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN
UNION ALL SELECT 'INTERACTIONS_CLEAN', COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.INTERACTIONS_CLEAN
UNION ALL SELECT 'CAMPAIGNS_CLEAN', COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.CAMPAIGNS_CLEAN
UNION ALL SELECT 'CAMPAIGN_PERFORMANCE_CLEAN', COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.CAMPAIGN_PERFORMANCE_CLEAN
ORDER BY table_name;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

-- =========================================================
-- PHASE 4: GOLD DATA PRODUCTS
-- Enterprise Data Mesh Gold Layer
-- =========================================================


-- =========================================================
-- CUSTOMER DOMAIN GOLD
-- =========================================================

CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360 AS
SELECT
    c.user_id,
    c.age,
    c.gender,
    c.country,
    c.city,
    c.signup_date,
    c.income_level,
    c.preferred_category,
    c.loyalty_tier,

    COUNT(DISTINCT p.purchase_id) AS total_purchases,
    COUNT(DISTINCT p.order_id) AS total_orders,
    COALESCE(SUM(p.total_amount), 0) AS lifetime_revenue,
    COALESCE(AVG(p.total_amount), 0) AS avg_purchase_value,
    MAX(p.order_date) AS last_purchase_date,

    COUNT(DISTINCT st.ticket_id) AS total_support_tickets,
    AVG(st.satisfaction_score) AS avg_satisfaction_score,

    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN s.is_converted = TRUE THEN s.session_id END) AS converted_sessions,

    CURRENT_TIMESTAMP() AS gold_created_at
FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN c
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
    ON c.user_id = p.user_id
LEFT JOIN CUSTOMER_DOMAIN_DB.SILVER.SUPPORT_TICKETS_CLEAN st
    ON c.user_id = st.user_id
LEFT JOIN MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN s
    ON c.user_id = s.user_id
GROUP BY
    c.user_id,
    c.age,
    c.gender,
    c.country,
    c.city,
    c.signup_date,
    c.income_level,
    c.preferred_category,
    c.loyalty_tier;


CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE AS
SELECT
    c.user_id,
    c.country,
    c.city,
    c.loyalty_tier,
    COUNT(DISTINCT p.purchase_id) AS purchase_count,
    COALESCE(SUM(p.total_amount), 0) AS lifetime_value,
    COALESCE(AVG(p.total_amount), 0) AS avg_order_value,
    MIN(p.order_date) AS first_purchase_date,
    MAX(p.order_date) AS last_purchase_date,
    DATEDIFF('day', MIN(p.order_date), MAX(p.order_date)) AS customer_purchase_span_days,
    CASE
        WHEN COALESCE(SUM(p.total_amount), 0) >= 5000 THEN 'high_value'
        WHEN COALESCE(SUM(p.total_amount), 0) >= 1000 THEN 'medium_value'
        ELSE 'low_value'
    END AS customer_value_segment,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN c
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
    ON c.user_id = p.user_id
GROUP BY
    c.user_id,
    c.country,
    c.city,
    c.loyalty_tier;


CREATE OR REPLACE TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_SUPPORT_SUMMARY AS
SELECT
    c.user_id,
    c.country,
    c.loyalty_tier,
    COUNT(DISTINCT st.ticket_id) AS total_tickets,
    COUNT(DISTINCT CASE WHEN st.ticket_status = 'closed' THEN st.ticket_id END) AS closed_tickets,
    COUNT(DISTINCT CASE WHEN st.priority = 'high' THEN st.ticket_id END) AS high_priority_tickets,
    AVG(st.satisfaction_score) AS avg_satisfaction_score,
    AVG(DATEDIFF('hour', st.created_ts, st.closed_ts)) AS avg_resolution_hours,
    MAX(st.created_ts) AS latest_ticket_created_ts,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN c
LEFT JOIN CUSTOMER_DOMAIN_DB.SILVER.SUPPORT_TICKETS_CLEAN st
    ON c.user_id = st.user_id
GROUP BY
    c.user_id,
    c.country,
    c.loyalty_tier;


-- =========================================================
-- PRODUCT DOMAIN GOLD
-- =========================================================

CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360 AS
SELECT
    pr.product_id,
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.brand,
    pr.price,
    pr.rating_avg,
    pr.review_count,
    pr.stock_quantity,
    pr.date_added,

    COUNT(DISTINCT pu.purchase_id) AS total_purchases,
    COALESCE(SUM(pu.quantity), 0) AS total_units_sold,
    COALESCE(SUM(pu.total_amount), 0) AS total_revenue,
    AVG(rv.rating) AS actual_avg_review_rating,
    COUNT(DISTINCT rv.review_id) AS total_reviews,

    COALESCE(SUM(inv.stock_on_hand), 0) AS total_stock_on_hand,
    COALESCE(SUM(inv.reserved_quantity), 0) AS total_reserved_quantity,

    CURRENT_TIMESTAMP() AS gold_created_at
FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN pr
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN pu
    ON pr.product_id = pu.product_id
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.REVIEWS_CLEAN rv
    ON pr.product_id = rv.product_id
LEFT JOIN INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN inv
    ON pr.product_id = inv.product_id
GROUP BY
    pr.product_id,
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.brand,
    pr.price,
    pr.rating_avg,
    pr.review_count,
    pr.stock_quantity,
    pr.date_added;


CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.GOLD.PRODUCT_PERFORMANCE AS
SELECT
    pr.product_id,
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.brand,
    COUNT(DISTINCT pu.purchase_id) AS purchase_count,
    COALESCE(SUM(pu.quantity), 0) AS units_sold,
    COALESCE(SUM(pu.total_amount), 0) AS revenue,
    AVG(rv.rating) AS avg_rating,
    COUNT(DISTINCT rv.review_id) AS review_count,
    COUNT(DISTINCT r.return_id) AS return_count,
    CASE
        WHEN COUNT(DISTINCT pu.purchase_id) = 0 THEN 0
        ELSE COUNT(DISTINCT r.return_id) / COUNT(DISTINCT pu.purchase_id)
    END AS return_rate,
    CASE
        WHEN COALESCE(SUM(pu.total_amount), 0) >= 10000 THEN 'top_performer'
        WHEN COALESCE(SUM(pu.total_amount), 0) >= 3000 THEN 'mid_performer'
        ELSE 'low_performer'
    END AS performance_segment,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN pr
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN pu
    ON pr.product_id = pu.product_id
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.REVIEWS_CLEAN rv
    ON pr.product_id = rv.product_id
LEFT JOIN SALES_DOMAIN_DB.SILVER.RETURNS_CLEAN r
    ON pr.product_id = r.product_id
GROUP BY
    pr.product_id,
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.brand;


CREATE OR REPLACE TABLE PRODUCT_DOMAIN_DB.GOLD.SUPPLIER_PERFORMANCE AS
SELECT
    s.supplier_id,
    s.supplier_name,
    s.brand,
    s.primary_category,
    s.country,
    s.city,
    s.supplier_status,
    s.lead_time_days,
    s.quality_score,
    COUNT(DISTINCT p.product_id) AS supplied_product_count,
    COALESCE(SUM(pu.total_amount), 0) AS supplier_brand_revenue,
    COALESCE(SUM(pu.quantity), 0) AS supplier_brand_units_sold,
    AVG(rv.rating) AS supplier_brand_avg_rating,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM PRODUCT_DOMAIN_DB.SILVER.SUPPLIERS_CLEAN s
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN p
    ON s.brand = p.brand
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN pu
    ON p.product_id = pu.product_id
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.REVIEWS_CLEAN rv
    ON p.product_id = rv.product_id
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.brand,
    s.primary_category,
    s.country,
    s.city,
    s.supplier_status,
    s.lead_time_days,
    s.quality_score;


-- =========================================================
-- SALES DOMAIN GOLD
-- =========================================================

CREATE OR REPLACE TABLE SALES_DOMAIN_DB.GOLD.SALES_FACT AS
SELECT
    p.purchase_id,
    p.order_id,
    p.user_id,
    p.product_id,
    p.session_id,
    p.interaction_id,
    p.quantity,
    p.unit_price,
    p.total_amount,
    p.order_date,

    c.country AS customer_country,
    c.city AS customer_city,
    c.loyalty_tier,

    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.brand,

    pay.payment_method,
    pay.payment_status,
    pay.currency_code,
    pay.fraud_score,

    CASE WHEN r.return_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_returned,
    r.return_reason,
    r.return_status,

    CASE WHEN rf.refund_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_refunded,
    rf.refund_amount,

    CURRENT_TIMESTAMP() AS gold_created_at
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
LEFT JOIN CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN c
    ON p.user_id = c.user_id
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN pr
    ON p.product_id = pr.product_id
LEFT JOIN SALES_DOMAIN_DB.SILVER.PAYMENTS_CLEAN pay
    ON p.purchase_id = pay.purchase_id
LEFT JOIN SALES_DOMAIN_DB.SILVER.RETURNS_CLEAN r
    ON p.purchase_id = r.purchase_id
LEFT JOIN SALES_DOMAIN_DB.SILVER.REFUNDS_CLEAN rf
    ON p.purchase_id = rf.purchase_id;


CREATE OR REPLACE TABLE SALES_DOMAIN_DB.GOLD.DAILY_SALES AS
SELECT
    order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT purchase_id) AS total_purchases,
    COUNT(DISTINCT user_id) AS unique_customers,
    SUM(quantity) AS total_units_sold,
    SUM(total_amount) AS gross_revenue,
    AVG(total_amount) AS avg_purchase_value,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN
GROUP BY order_date;


CREATE OR REPLACE TABLE SALES_DOMAIN_DB.GOLD.MONTHLY_REVENUE AS
SELECT
    DATE_TRUNC('month', order_date) AS revenue_month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS unique_customers,
    SUM(quantity) AS total_units_sold,
    SUM(total_amount) AS gross_revenue,
    AVG(total_amount) AS avg_purchase_value,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN
GROUP BY DATE_TRUNC('month', order_date);


CREATE OR REPLACE TABLE SALES_DOMAIN_DB.GOLD.RETURN_ANALYTICS AS
SELECT
    r.return_id,
    r.order_id,
    r.purchase_id,
    r.user_id,
    r.product_id,
    r.return_ts,
    r.return_reason,
    r.return_status,
    r.quantity_returned,
    r.condition_received,
    p.total_amount AS original_purchase_amount,
    rf.refund_amount,
    rf.refund_status,
    rf.refund_method,
    pr.category,
    pr.brand,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM SALES_DOMAIN_DB.SILVER.RETURNS_CLEAN r
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
    ON r.purchase_id = p.purchase_id
LEFT JOIN SALES_DOMAIN_DB.SILVER.REFUNDS_CLEAN rf
    ON r.return_id = rf.return_id
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN pr
    ON r.product_id = pr.product_id;


-- =========================================================
-- INVENTORY DOMAIN GOLD
-- =========================================================

CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS AS
SELECT
    i.inventory_id,
    i.product_id,
    p.product_name,
    p.category,
    p.brand,
    i.warehouse_id,
    w.warehouse_name,
    w.country,
    w.city,
    i.stock_on_hand,
    i.reserved_quantity,
    i.reorder_point,
    i.reorder_quantity,
    i.inventory_status,
    i.last_stocktake_date,
    i.stock_on_hand - i.reserved_quantity AS available_stock,
    CASE
        WHEN i.stock_on_hand <= i.reorder_point THEN 'reorder_required'
        WHEN i.stock_on_hand <= i.reorder_point * 1.5 THEN 'watch'
        ELSE 'healthy'
    END AS stock_health_status,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN i
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN p
    ON i.product_id = p.product_id
LEFT JOIN INVENTORY_DOMAIN_DB.SILVER.WAREHOUSES_CLEAN w
    ON i.warehouse_id = w.warehouse_id;


CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.GOLD.STOCK_ALERTS AS
SELECT
    inventory_id,
    product_id,
    product_name,
    category,
    brand,
    warehouse_id,
    warehouse_name,
    country,
    city,
    stock_on_hand,
    reserved_quantity,
    available_stock,
    reorder_point,
    reorder_quantity,
    stock_health_status,
    CASE
        WHEN available_stock <= 0 THEN 'out_of_stock'
        WHEN stock_health_status = 'reorder_required' THEN 'low_stock'
        ELSE 'normal'
    END AS alert_type,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS
WHERE stock_health_status IN ('reorder_required', 'watch')
   OR available_stock <= 0;


CREATE OR REPLACE TABLE INVENTORY_DOMAIN_DB.GOLD.SHIPPING_PERFORMANCE AS
SELECT
    s.shipment_id,
    s.order_id,
    s.purchase_id,
    s.user_id,
    s.warehouse_id,
    w.warehouse_name,
    w.country,
    w.city,
    s.carrier,
    s.shipment_status,
    s.shipped_ts,
    s.promised_delivery_ts,
    s.delivered_ts,
    s.is_late,
    s.shipping_cost,
    DATEDIFF('day', s.shipped_ts, s.delivered_ts) AS delivery_days,
    DATEDIFF('hour', s.promised_delivery_ts, s.delivered_ts) AS delivery_delay_hours,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM INVENTORY_DOMAIN_DB.SILVER.SHIPMENTS_CLEAN s
LEFT JOIN INVENTORY_DOMAIN_DB.SILVER.WAREHOUSES_CLEAN w
    ON s.warehouse_id = w.warehouse_id;


-- =========================================================
-- MARKETING DOMAIN GOLD
-- =========================================================

CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.GOLD.CAMPAIGN_ROI AS
SELECT
    c.campaign_id,
    c.campaign_name,
    c.channel,
    c.objective,
    c.start_date,
    c.end_date,
    c.budget_amount,
    c.currency_code,
    c.target_country,
    c.campaign_status,

    cp.sessions,
    cp.conversions,
    cp.spend_amount,
    cp.impressions,
    cp.clicks,

    CASE WHEN cp.impressions = 0 THEN 0 ELSE cp.clicks / cp.impressions END AS click_through_rate,
    CASE WHEN cp.sessions = 0 THEN 0 ELSE cp.conversions / cp.sessions END AS conversion_rate,
    CASE WHEN cp.conversions = 0 THEN 0 ELSE cp.spend_amount / cp.conversions END AS cost_per_conversion,

    CURRENT_TIMESTAMP() AS gold_created_at
FROM MARKETING_DOMAIN_DB.SILVER.CAMPAIGNS_CLEAN c
LEFT JOIN MARKETING_DOMAIN_DB.SILVER.CAMPAIGN_PERFORMANCE_CLEAN cp
    ON c.campaign_id = cp.campaign_id;


CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.GOLD.CONVERSION_FUNNEL AS
SELECT
    s.referrer_source,
    s.device_type,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN s.is_converted = TRUE THEN s.session_id END) AS converted_sessions,
    COUNT(DISTINCT i.interaction_id) AS total_interactions,
    COUNT(DISTINCT p.purchase_id) AS total_purchases,
    COALESCE(SUM(p.total_amount), 0) AS attributed_revenue,
    CASE
        WHEN COUNT(DISTINCT s.session_id) = 0 THEN 0
        ELSE COUNT(DISTINCT CASE WHEN s.is_converted = TRUE THEN s.session_id END)
             / COUNT(DISTINCT s.session_id)
    END AS session_conversion_rate,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN s
LEFT JOIN MARKETING_DOMAIN_DB.SILVER.INTERACTIONS_CLEAN i
    ON s.session_id = i.session_id
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
    ON s.session_id = p.session_id
GROUP BY
    s.referrer_source,
    s.device_type;


CREATE OR REPLACE TABLE MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR AS
SELECT
    s.user_id,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT i.interaction_id) AS total_interactions,
    COUNT(DISTINCT i.product_id) AS unique_products_viewed,
    AVG(i.dwell_time_ms) AS avg_dwell_time_ms,
    COUNT(DISTINCT CASE WHEN s.is_converted = TRUE THEN s.session_id END) AS converted_sessions,
    COUNT(DISTINCT p.purchase_id) AS purchases,
    COALESCE(SUM(p.total_amount), 0) AS revenue,
    CURRENT_TIMESTAMP() AS gold_created_at
FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN s
LEFT JOIN MARKETING_DOMAIN_DB.SILVER.INTERACTIONS_CLEAN i
    ON s.session_id = i.session_id
LEFT JOIN SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
    ON s.session_id = p.session_id
GROUP BY s.user_id;


-- =========================================================
-- GOLD VALIDATION
-- =========================================================

SELECT 'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360' AS table_name, COUNT(*) AS row_count FROM CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360
UNION ALL SELECT 'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE', COUNT(*) FROM CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE
UNION ALL SELECT 'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_SUPPORT_SUMMARY', COUNT(*) FROM CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_SUPPORT_SUMMARY

UNION ALL SELECT 'PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360', COUNT(*) FROM PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360
UNION ALL SELECT 'PRODUCT_DOMAIN_DB.GOLD.PRODUCT_PERFORMANCE', COUNT(*) FROM PRODUCT_DOMAIN_DB.GOLD.PRODUCT_PERFORMANCE
UNION ALL SELECT 'PRODUCT_DOMAIN_DB.GOLD.SUPPLIER_PERFORMANCE', COUNT(*) FROM PRODUCT_DOMAIN_DB.GOLD.SUPPLIER_PERFORMANCE

UNION ALL SELECT 'SALES_DOMAIN_DB.GOLD.SALES_FACT', COUNT(*) FROM SALES_DOMAIN_DB.GOLD.SALES_FACT
UNION ALL SELECT 'SALES_DOMAIN_DB.GOLD.DAILY_SALES', COUNT(*) FROM SALES_DOMAIN_DB.GOLD.DAILY_SALES
UNION ALL SELECT 'SALES_DOMAIN_DB.GOLD.MONTHLY_REVENUE', COUNT(*) FROM SALES_DOMAIN_DB.GOLD.MONTHLY_REVENUE
UNION ALL SELECT 'SALES_DOMAIN_DB.GOLD.RETURN_ANALYTICS', COUNT(*) FROM SALES_DOMAIN_DB.GOLD.RETURN_ANALYTICS

UNION ALL SELECT 'INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS', COUNT(*) FROM INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS
UNION ALL SELECT 'INVENTORY_DOMAIN_DB.GOLD.STOCK_ALERTS', COUNT(*) FROM INVENTORY_DOMAIN_DB.GOLD.STOCK_ALERTS
UNION ALL SELECT 'INVENTORY_DOMAIN_DB.GOLD.SHIPPING_PERFORMANCE', COUNT(*) FROM INVENTORY_DOMAIN_DB.GOLD.SHIPPING_PERFORMANCE

UNION ALL SELECT 'MARKETING_DOMAIN_DB.GOLD.CAMPAIGN_ROI', COUNT(*) FROM MARKETING_DOMAIN_DB.GOLD.CAMPAIGN_ROI
UNION ALL SELECT 'MARKETING_DOMAIN_DB.GOLD.CONVERSION_FUNNEL', COUNT(*) FROM MARKETING_DOMAIN_DB.GOLD.CONVERSION_FUNNEL
UNION ALL SELECT 'MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR', COUNT(*) FROM MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR

ORDER BY table_name;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

-- =========================================================
-- PHASE 5: CROSS-DOMAIN ANALYTICS VIEWS
-- =========================================================

CREATE DATABASE IF NOT EXISTS ANALYTICS_DB;
CREATE SCHEMA IF NOT EXISTS ANALYTICS_DB.RETAIL_ANALYTICS;

USE DATABASE ANALYTICS_DB;
USE SCHEMA RETAIL_ANALYTICS;

-- =========================================================
-- 1. EXECUTIVE REVENUE DASHBOARD
-- =========================================================

CREATE OR REPLACE VIEW EXECUTIVE_REVENUE_DASHBOARD AS
SELECT
    ds.order_date,
    DATE_TRUNC('month', ds.order_date) AS revenue_month,
    ds.total_orders,
    ds.total_purchases,
    ds.unique_customers,
    ds.total_units_sold,
    ds.gross_revenue,
    ds.avg_purchase_value,

    COUNT(DISTINCT sf.product_id) AS unique_products_sold,
    COUNT(DISTINCT sf.customer_country) AS active_countries,

    SUM(CASE WHEN sf.is_returned = TRUE THEN sf.total_amount ELSE 0 END) AS returned_revenue,
    SUM(CASE WHEN sf.is_refunded = TRUE THEN sf.refund_amount ELSE 0 END) AS refunded_amount,

    ds.gross_revenue
        - COALESCE(SUM(CASE WHEN sf.is_refunded = TRUE THEN sf.refund_amount ELSE 0 END), 0)
        AS net_revenue

FROM SALES_DOMAIN_DB.GOLD.DAILY_SALES ds
LEFT JOIN SALES_DOMAIN_DB.GOLD.SALES_FACT sf
    ON ds.order_date = sf.order_date
GROUP BY
    ds.order_date,
    DATE_TRUNC('month', ds.order_date),
    ds.total_orders,
    ds.total_purchases,
    ds.unique_customers,
    ds.total_units_sold,
    ds.gross_revenue,
    ds.avg_purchase_value;


-- =========================================================
-- 2. CUSTOMER 360 ANALYTICS
-- =========================================================

CREATE OR REPLACE VIEW CUSTOMER_360_ANALYTICS AS
SELECT
    c.user_id,
    c.age,
    c.gender,
    c.country,
    c.city,
    c.signup_date,
    c.income_level,
    c.preferred_category,
    c.loyalty_tier,

    c.total_purchases,
    c.total_orders,
    c.lifetime_revenue,
    c.avg_purchase_value,
    c.last_purchase_date,

    clv.customer_value_segment,
    clv.first_purchase_date,
    clv.customer_purchase_span_days,

    c.total_support_tickets,
    c.avg_satisfaction_score,

    c.total_sessions,
    c.converted_sessions,

    CASE
        WHEN c.total_sessions = 0 THEN 0
        ELSE c.converted_sessions / c.total_sessions
    END AS customer_conversion_rate

FROM CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360 c
LEFT JOIN CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE clv
    ON c.user_id = clv.user_id;


-- =========================================================
-- 3. PRODUCT PERFORMANCE ANALYTICS
-- =========================================================

CREATE OR REPLACE VIEW PRODUCT_PERFORMANCE_ANALYTICS AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.price,
    p.rating_avg,
    p.total_purchases,
    p.total_units_sold,
    p.total_revenue,
    p.actual_avg_review_rating,
    p.total_reviews,
    p.total_stock_on_hand,
    p.total_reserved_quantity,

    pp.return_count,
    pp.return_rate,
    pp.performance_segment,

    CASE
        WHEN p.total_stock_on_hand <= 0 THEN 'out_of_stock'
        WHEN p.total_stock_on_hand <= 10 THEN 'low_stock'
        ELSE 'in_stock'
    END AS product_stock_status

FROM PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360 p
LEFT JOIN PRODUCT_DOMAIN_DB.GOLD.PRODUCT_PERFORMANCE pp
    ON p.product_id = pp.product_id;


-- =========================================================
-- 4. MARKETING ATTRIBUTION ANALYTICS
-- =========================================================

CREATE OR REPLACE VIEW MARKETING_ATTRIBUTION_ANALYTICS AS
SELECT
    cf.referrer_source,
    cf.device_type,
    cf.total_sessions,
    cf.converted_sessions,
    cf.total_interactions,
    cf.total_purchases,
    cf.attributed_revenue,
    cf.session_conversion_rate,

    CASE
        WHEN cf.total_purchases = 0 THEN 0
        ELSE cf.attributed_revenue / cf.total_purchases
    END AS revenue_per_purchase,

    CASE
        WHEN cf.total_sessions = 0 THEN 0
        ELSE cf.attributed_revenue / cf.total_sessions
    END AS revenue_per_session

FROM MARKETING_DOMAIN_DB.GOLD.CONVERSION_FUNNEL cf;


-- =========================================================
-- 5. INVENTORY RISK DASHBOARD
-- =========================================================

CREATE OR REPLACE VIEW INVENTORY_RISK_DASHBOARD AS
SELECT
    i.product_id,
    i.product_name,
    i.category,
    i.brand,
    i.warehouse_id,
    i.warehouse_name,
    i.country,
    i.city,
    i.stock_on_hand,
    i.reserved_quantity,
    i.available_stock,
    i.reorder_point,
    i.reorder_quantity,
    i.stock_health_status,

    pp.total_units_sold,
    pp.total_revenue,

    CASE
        WHEN i.available_stock <= 0 THEN 'critical'
        WHEN i.stock_health_status = 'reorder_required' THEN 'high'
        WHEN i.stock_health_status = 'watch' THEN 'medium'
        ELSE 'low'
    END AS inventory_risk_level

FROM INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS i
LEFT JOIN PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360 pp
    ON i.product_id = pp.product_id;


-- =========================================================
-- 6. RETURNS AND REFUNDS ANALYTICS
-- =========================================================

CREATE OR REPLACE VIEW RETURNS_REFUNDS_ANALYTICS AS
SELECT
    r.return_id,
    r.order_id,
    r.purchase_id,
    r.user_id,
    r.product_id,
    r.return_ts,
    r.return_reason,
    r.return_status,
    r.quantity_returned,
    r.condition_received,
    r.original_purchase_amount,
    r.refund_amount,
    r.refund_status,
    r.refund_method,
    r.category,
    r.brand,

    CASE
        WHEN r.original_purchase_amount = 0 THEN 0
        ELSE r.refund_amount / r.original_purchase_amount
    END AS refund_ratio

FROM SALES_DOMAIN_DB.GOLD.RETURN_ANALYTICS r;


-- =========================================================
-- 7. CUSTOMER JOURNEY VIEW
-- =========================================================

CREATE OR REPLACE VIEW CUSTOMER_JOURNEY_ANALYTICS AS
SELECT
    ub.user_id,
    c.country,
    c.city,
    c.loyalty_tier,
    c.customer_value_segment,

    ub.total_sessions,
    ub.total_interactions,
    ub.unique_products_viewed,
    ub.avg_dwell_time_ms,
    ub.converted_sessions,
    ub.purchases,
    ub.revenue,

    c.total_support_tickets,
    c.avg_satisfaction_score,

    CASE
        WHEN ub.total_sessions = 0 THEN 0
        ELSE ub.converted_sessions / ub.total_sessions
    END AS journey_conversion_rate,

    CASE
        WHEN ub.unique_products_viewed = 0 THEN 0
        ELSE ub.purchases / ub.unique_products_viewed
    END AS product_view_to_purchase_rate

FROM MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR ub
LEFT JOIN ANALYTICS_DB.RETAIL_ANALYTICS.CUSTOMER_360_ANALYTICS c
    ON ub.user_id = c.user_id;


-- =========================================================
-- 8. SALES BY COUNTRY, CATEGORY, MONTH
-- =========================================================

CREATE OR REPLACE VIEW SALES_BY_COUNTRY_CATEGORY_MONTH AS
SELECT
    DATE_TRUNC('month', sf.order_date) AS sales_month,
    sf.customer_country,
    sf.category,
    sf.subcategory,
    sf.brand,

    COUNT(DISTINCT sf.order_id) AS total_orders,
    COUNT(DISTINCT sf.purchase_id) AS total_purchases,
    COUNT(DISTINCT sf.user_id) AS unique_customers,
    SUM(sf.quantity) AS total_units_sold,
    SUM(sf.total_amount) AS gross_revenue,

    SUM(CASE WHEN sf.is_returned = TRUE THEN sf.total_amount ELSE 0 END) AS returned_revenue,
    SUM(CASE WHEN sf.is_refunded = TRUE THEN sf.refund_amount ELSE 0 END) AS refunded_amount,

    SUM(sf.total_amount)
        - COALESCE(SUM(CASE WHEN sf.is_refunded = TRUE THEN sf.refund_amount ELSE 0 END), 0)
        AS net_revenue

FROM SALES_DOMAIN_DB.GOLD.SALES_FACT sf
GROUP BY
    DATE_TRUNC('month', sf.order_date),
    sf.customer_country,
    sf.category,
    sf.subcategory,
    sf.brand;


-- =========================================================
-- 9. CAMPAIGN ROI ANALYTICS
-- =========================================================

CREATE OR REPLACE VIEW CAMPAIGN_ROI_ANALYTICS AS
SELECT
    campaign_id,
    campaign_name,
    channel,
    objective,
    start_date,
    end_date,
    budget_amount,
    spend_amount,
    currency_code,
    target_country,
    campaign_status,
    sessions,
    conversions,
    impressions,
    clicks,
    click_through_rate,
    conversion_rate,
    cost_per_conversion,

    CASE
        WHEN spend_amount = 0 THEN 0
        ELSE (budget_amount - spend_amount) / spend_amount
    END AS budget_efficiency_ratio

FROM MARKETING_DOMAIN_DB.GOLD.CAMPAIGN_ROI;


-- =========================================================
-- 10. SUPPLY CHAIN ANALYTICS
-- =========================================================

CREATE OR REPLACE VIEW SUPPLY_CHAIN_ANALYTICS AS
SELECT
    sp.supplier_id,
    sp.supplier_name,
    sp.brand,
    sp.primary_category,
    sp.country AS supplier_country,
    sp.city AS supplier_city,
    sp.supplier_status,
    sp.lead_time_days,
    sp.quality_score,
    sp.supplied_product_count,
    sp.supplier_brand_revenue,
    sp.supplier_brand_units_sold,
    sp.supplier_brand_avg_rating,

    COUNT(DISTINCT ir.product_id) AS products_with_inventory,
    SUM(ir.available_stock) AS total_available_stock,
    COUNT(DISTINCT CASE WHEN ir.inventory_risk_level IN ('critical', 'high') THEN ir.product_id END) AS high_risk_products

FROM PRODUCT_DOMAIN_DB.GOLD.SUPPLIER_PERFORMANCE sp
LEFT JOIN ANALYTICS_DB.RETAIL_ANALYTICS.INVENTORY_RISK_DASHBOARD ir
    ON sp.brand = ir.brand
GROUP BY
    sp.supplier_id,
    sp.supplier_name,
    sp.brand,
    sp.primary_category,
    sp.country,
    sp.city,
    sp.supplier_status,
    sp.lead_time_days,
    sp.quality_score,
    sp.supplied_product_count,
    sp.supplier_brand_revenue,
    sp.supplier_brand_units_sold,
    sp.supplier_brand_avg_rating;


-- =========================================================
-- 11. DOMAIN DATA PRODUCT CATALOG
-- =========================================================

CREATE OR REPLACE VIEW DOMAIN_DATA_PRODUCT_CATALOG AS
SELECT
    'CUSTOMER' AS domain_name,
    'CUSTOMER_360' AS data_product_name,
    'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360' AS object_name,
    'Customer profile, purchase, support, and session summary' AS description
UNION ALL
SELECT
    'CUSTOMER',
    'CUSTOMER_LIFETIME_VALUE',
    'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE',
    'Customer lifetime value and value segmentation'
UNION ALL
SELECT
    'CUSTOMER',
    'CUSTOMER_SUPPORT_SUMMARY',
    'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_SUPPORT_SUMMARY',
    'Support ticket and satisfaction summary by customer'
UNION ALL
SELECT
    'PRODUCT',
    'PRODUCT_360',
    'PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360',
    'Product profile, revenue, reviews, and inventory summary'
UNION ALL
SELECT
    'PRODUCT',
    'PRODUCT_PERFORMANCE',
    'PRODUCT_DOMAIN_DB.GOLD.PRODUCT_PERFORMANCE',
    'Product revenue, return rate, and performance segmentation'
UNION ALL
SELECT
    'PRODUCT',
    'SUPPLIER_PERFORMANCE',
    'PRODUCT_DOMAIN_DB.GOLD.SUPPLIER_PERFORMANCE',
    'Supplier, product, revenue, and quality analytics'
UNION ALL
SELECT
    'SALES',
    'SALES_FACT',
    'SALES_DOMAIN_DB.GOLD.SALES_FACT',
    'Cross-domain sales transaction fact table'
UNION ALL
SELECT
    'SALES',
    'DAILY_SALES',
    'SALES_DOMAIN_DB.GOLD.DAILY_SALES',
    'Daily sales KPI table'
UNION ALL
SELECT
    'SALES',
    'MONTHLY_REVENUE',
    'SALES_DOMAIN_DB.GOLD.MONTHLY_REVENUE',
    'Monthly revenue KPI table'
UNION ALL
SELECT
    'SALES',
    'RETURN_ANALYTICS',
    'SALES_DOMAIN_DB.GOLD.RETURN_ANALYTICS',
    'Returns and refunds analytics table'
UNION ALL
SELECT
    'INVENTORY',
    'INVENTORY_STATUS',
    'INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS',
    'Product warehouse inventory status'
UNION ALL
SELECT
    'INVENTORY',
    'STOCK_ALERTS',
    'INVENTORY_DOMAIN_DB.GOLD.STOCK_ALERTS',
    'Low stock and reorder alerts'
UNION ALL
SELECT
    'INVENTORY',
    'SHIPPING_PERFORMANCE',
    'INVENTORY_DOMAIN_DB.GOLD.SHIPPING_PERFORMANCE',
    'Shipment delivery and delay performance'
UNION ALL
SELECT
    'MARKETING',
    'CAMPAIGN_ROI',
    'MARKETING_DOMAIN_DB.GOLD.CAMPAIGN_ROI',
    'Campaign spend, conversion, and ROI metrics'
UNION ALL
SELECT
    'MARKETING',
    'CONVERSION_FUNNEL',
    'MARKETING_DOMAIN_DB.GOLD.CONVERSION_FUNNEL',
    'Session, interaction, conversion, and revenue funnel'
UNION ALL
SELECT
    'MARKETING',
    'USER_BEHAVIOR',
    'MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR',
    'User behavior, engagement, and revenue summary';


-- =========================================================
-- VALIDATION
-- =========================================================

SELECT 'EXECUTIVE_REVENUE_DASHBOARD' AS view_name, COUNT(*) AS row_count FROM EXECUTIVE_REVENUE_DASHBOARD
UNION ALL SELECT 'CUSTOMER_360_ANALYTICS', COUNT(*) FROM CUSTOMER_360_ANALYTICS
UNION ALL SELECT 'PRODUCT_PERFORMANCE_ANALYTICS', COUNT(*) FROM PRODUCT_PERFORMANCE_ANALYTICS
UNION ALL SELECT 'MARKETING_ATTRIBUTION_ANALYTICS', COUNT(*) FROM MARKETING_ATTRIBUTION_ANALYTICS
UNION ALL SELECT 'INVENTORY_RISK_DASHBOARD', COUNT(*) FROM INVENTORY_RISK_DASHBOARD
UNION ALL SELECT 'RETURNS_REFUNDS_ANALYTICS', COUNT(*) FROM RETURNS_REFUNDS_ANALYTICS
UNION ALL SELECT 'CUSTOMER_JOURNEY_ANALYTICS', COUNT(*) FROM CUSTOMER_JOURNEY_ANALYTICS
UNION ALL SELECT 'SALES_BY_COUNTRY_CATEGORY_MONTH', COUNT(*) FROM SALES_BY_COUNTRY_CATEGORY_MONTH
UNION ALL SELECT 'CAMPAIGN_ROI_ANALYTICS', COUNT(*) FROM CAMPAIGN_ROI_ANALYTICS
UNION ALL SELECT 'SUPPLY_CHAIN_ANALYTICS', COUNT(*) FROM SUPPLY_CHAIN_ANALYTICS
UNION ALL SELECT 'DOMAIN_DATA_PRODUCT_CATALOG', COUNT(*) FROM DOMAIN_DATA_PRODUCT_CATALOG
ORDER BY view_name;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

-- =========================================================
-- PHASE 6: GOVERNANCE
-- Roles, Grants, Tags, Masking Policies, Row Access Policies
-- =========================================================


-- =========================================================
-- 1. ROLE HIERARCHY
-- =========================================================

CREATE ROLE IF NOT EXISTS DATAMESH_ADMIN_ROLE;
CREATE ROLE IF NOT EXISTS CUSTOMER_DOMAIN_OWNER_ROLE;
CREATE ROLE IF NOT EXISTS PRODUCT_DOMAIN_OWNER_ROLE;
CREATE ROLE IF NOT EXISTS SALES_DOMAIN_OWNER_ROLE;
CREATE ROLE IF NOT EXISTS INVENTORY_DOMAIN_OWNER_ROLE;
CREATE ROLE IF NOT EXISTS MARKETING_DOMAIN_OWNER_ROLE;
CREATE ROLE IF NOT EXISTS ANALYTICS_CONSUMER_ROLE;
CREATE ROLE IF NOT EXISTS DATA_STEWARD_ROLE;

GRANT ROLE DATAMESH_ADMIN_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE CUSTOMER_DOMAIN_OWNER_ROLE TO ROLE DATAMESH_ADMIN_ROLE;
GRANT ROLE PRODUCT_DOMAIN_OWNER_ROLE TO ROLE DATAMESH_ADMIN_ROLE;
GRANT ROLE SALES_DOMAIN_OWNER_ROLE TO ROLE DATAMESH_ADMIN_ROLE;
GRANT ROLE INVENTORY_DOMAIN_OWNER_ROLE TO ROLE DATAMESH_ADMIN_ROLE;
GRANT ROLE MARKETING_DOMAIN_OWNER_ROLE TO ROLE DATAMESH_ADMIN_ROLE;
GRANT ROLE ANALYTICS_CONSUMER_ROLE TO ROLE DATAMESH_ADMIN_ROLE;
GRANT ROLE DATA_STEWARD_ROLE TO ROLE DATAMESH_ADMIN_ROLE;


-- =========================================================
-- 2. WAREHOUSE USAGE
-- =========================================================

GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE DATAMESH_ADMIN_ROLE;
GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE CUSTOMER_DOMAIN_OWNER_ROLE;
GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE PRODUCT_DOMAIN_OWNER_ROLE;
GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE SALES_DOMAIN_OWNER_ROLE;
GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE INVENTORY_DOMAIN_OWNER_ROLE;
GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE MARKETING_DOMAIN_OWNER_ROLE;
GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE ANALYTICS_CONSUMER_ROLE;
GRANT USAGE ON WAREHOUSE WH_DATAMESH_XS TO ROLE DATA_STEWARD_ROLE;


-- =========================================================
-- 3. DOMAIN DATABASE GRANTS
-- =========================================================

GRANT USAGE ON DATABASE CUSTOMER_DOMAIN_DB TO ROLE CUSTOMER_DOMAIN_OWNER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE CUSTOMER_DOMAIN_DB TO ROLE CUSTOMER_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE CUSTOMER_DOMAIN_DB TO ROLE CUSTOMER_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL VIEWS IN DATABASE CUSTOMER_DOMAIN_DB TO ROLE CUSTOMER_DOMAIN_OWNER_ROLE;

GRANT USAGE ON DATABASE PRODUCT_DOMAIN_DB TO ROLE PRODUCT_DOMAIN_OWNER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE PRODUCT_DOMAIN_DB TO ROLE PRODUCT_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE PRODUCT_DOMAIN_DB TO ROLE PRODUCT_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL VIEWS IN DATABASE PRODUCT_DOMAIN_DB TO ROLE PRODUCT_DOMAIN_OWNER_ROLE;

GRANT USAGE ON DATABASE SALES_DOMAIN_DB TO ROLE SALES_DOMAIN_OWNER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE SALES_DOMAIN_DB TO ROLE SALES_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE SALES_DOMAIN_DB TO ROLE SALES_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL VIEWS IN DATABASE SALES_DOMAIN_DB TO ROLE SALES_DOMAIN_OWNER_ROLE;

GRANT USAGE ON DATABASE INVENTORY_DOMAIN_DB TO ROLE INVENTORY_DOMAIN_OWNER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE INVENTORY_DOMAIN_DB TO ROLE INVENTORY_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE INVENTORY_DOMAIN_DB TO ROLE INVENTORY_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL VIEWS IN DATABASE INVENTORY_DOMAIN_DB TO ROLE INVENTORY_DOMAIN_OWNER_ROLE;

GRANT USAGE ON DATABASE MARKETING_DOMAIN_DB TO ROLE MARKETING_DOMAIN_OWNER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE MARKETING_DOMAIN_DB TO ROLE MARKETING_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE MARKETING_DOMAIN_DB TO ROLE MARKETING_DOMAIN_OWNER_ROLE;
GRANT SELECT ON ALL VIEWS IN DATABASE MARKETING_DOMAIN_DB TO ROLE MARKETING_DOMAIN_OWNER_ROLE;


-- =========================================================
-- 4. ANALYTICS CONSUMER GRANTS
-- =========================================================

GRANT USAGE ON DATABASE ANALYTICS_DB TO ROLE ANALYTICS_CONSUMER_ROLE;
GRANT USAGE ON SCHEMA ANALYTICS_DB.RETAIL_ANALYTICS TO ROLE ANALYTICS_CONSUMER_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA ANALYTICS_DB.RETAIL_ANALYTICS TO ROLE ANALYTICS_CONSUMER_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA ANALYTICS_DB.RETAIL_ANALYTICS TO ROLE ANALYTICS_CONSUMER_ROLE;


-- =========================================================
-- 5. GOVERNANCE DATABASE
-- =========================================================

CREATE DATABASE IF NOT EXISTS GOVERNANCE_DB;
CREATE SCHEMA IF NOT EXISTS GOVERNANCE_DB.POLICIES;
CREATE SCHEMA IF NOT EXISTS GOVERNANCE_DB.AUDIT;

GRANT USAGE ON DATABASE GOVERNANCE_DB TO ROLE DATA_STEWARD_ROLE;
GRANT USAGE ON SCHEMA GOVERNANCE_DB.POLICIES TO ROLE DATA_STEWARD_ROLE;
GRANT USAGE ON SCHEMA GOVERNANCE_DB.AUDIT TO ROLE DATA_STEWARD_ROLE;


-- =========================================================
-- 6. GOVERNANCE TAGS
-- =========================================================

CREATE TAG IF NOT EXISTS GOVERNANCE_DB.POLICIES.DATA_DOMAIN;
CREATE TAG IF NOT EXISTS GOVERNANCE_DB.POLICIES.DATA_CLASSIFICATION;
CREATE TAG IF NOT EXISTS GOVERNANCE_DB.POLICIES.DATA_PRODUCT;
CREATE TAG IF NOT EXISTS GOVERNANCE_DB.POLICIES.DATA_OWNER;
CREATE TAG IF NOT EXISTS GOVERNANCE_DB.POLICIES.SENSITIVITY_LEVEL;

ALTER TABLE CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
SET TAG GOVERNANCE_DB.POLICIES.DATA_DOMAIN = 'CUSTOMER',
        GOVERNANCE_DB.POLICIES.DATA_CLASSIFICATION = 'PII',
        GOVERNANCE_DB.POLICIES.DATA_PRODUCT = 'CUSTOMER_PROFILE',
        GOVERNANCE_DB.POLICIES.DATA_OWNER = 'CUSTOMER_DOMAIN_OWNER',
        GOVERNANCE_DB.POLICIES.SENSITIVITY_LEVEL = 'HIGH';

ALTER TABLE SALES_DOMAIN_DB.GOLD.SALES_FACT
SET TAG GOVERNANCE_DB.POLICIES.DATA_DOMAIN = 'SALES',
        GOVERNANCE_DB.POLICIES.DATA_CLASSIFICATION = 'CONFIDENTIAL',
        GOVERNANCE_DB.POLICIES.DATA_PRODUCT = 'SALES_FACT',
        GOVERNANCE_DB.POLICIES.DATA_OWNER = 'SALES_DOMAIN_OWNER',
        GOVERNANCE_DB.POLICIES.SENSITIVITY_LEVEL = 'MEDIUM';

ALTER TABLE PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360
SET TAG GOVERNANCE_DB.POLICIES.DATA_DOMAIN = 'PRODUCT',
        GOVERNANCE_DB.POLICIES.DATA_CLASSIFICATION = 'INTERNAL',
        GOVERNANCE_DB.POLICIES.DATA_PRODUCT = 'PRODUCT_360',
        GOVERNANCE_DB.POLICIES.DATA_OWNER = 'PRODUCT_DOMAIN_OWNER',
        GOVERNANCE_DB.POLICIES.SENSITIVITY_LEVEL = 'LOW';

ALTER TABLE INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS
SET TAG GOVERNANCE_DB.POLICIES.DATA_DOMAIN = 'INVENTORY',
        GOVERNANCE_DB.POLICIES.DATA_CLASSIFICATION = 'INTERNAL',
        GOVERNANCE_DB.POLICIES.DATA_PRODUCT = 'INVENTORY_STATUS',
        GOVERNANCE_DB.POLICIES.DATA_OWNER = 'INVENTORY_DOMAIN_OWNER',
        GOVERNANCE_DB.POLICIES.SENSITIVITY_LEVEL = 'LOW';

ALTER TABLE MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR
SET TAG GOVERNANCE_DB.POLICIES.DATA_DOMAIN = 'MARKETING',
        GOVERNANCE_DB.POLICIES.DATA_CLASSIFICATION = 'CONFIDENTIAL',
        GOVERNANCE_DB.POLICIES.DATA_PRODUCT = 'USER_BEHAVIOR',
        GOVERNANCE_DB.POLICIES.DATA_OWNER = 'MARKETING_DOMAIN_OWNER',
        GOVERNANCE_DB.POLICIES.SENSITIVITY_LEVEL = 'MEDIUM';


-- =========================================================
-- 7. MASKING POLICIES
-- =========================================================
CREATE MASKING POLICY IF NOT EXISTS GOVERNANCE_DB.POLICIES.MASK_USER_ID AS
(val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN','DATAMESH_ADMIN_ROLE','CUSTOMER_DOMAIN_OWNER_ROLE','DATA_STEWARD_ROLE')
        THEN val
        ELSE SHA2(val)
    END;

CREATE MASKING POLICY IF NOT EXISTS GOVERNANCE_DB.POLICIES.MASK_CITY AS
(val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN','DATAMESH_ADMIN_ROLE','CUSTOMER_DOMAIN_OWNER_ROLE','DATA_STEWARD_ROLE')
        THEN val
        ELSE 'MASKED_CITY'
    END;

CREATE MASKING POLICY IF NOT EXISTS GOVERNANCE_DB.POLICIES.MASK_INCOME_LEVEL AS
(val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN','DATAMESH_ADMIN_ROLE','CUSTOMER_DOMAIN_OWNER_ROLE','DATA_STEWARD_ROLE')
        THEN val
        ELSE 'MASKED_INCOME'
    END;

CREATE MASKING POLICY IF NOT EXISTS GOVERNANCE_DB.POLICIES.MASK_TRANSACTION_REFERENCE AS
(val STRING) RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN','DATAMESH_ADMIN_ROLE','SALES_DOMAIN_OWNER_ROLE','DATA_STEWARD_ROLE')
        THEN val
        ELSE 'MASKED_TRANSACTION'
    END;


-- =========================================================
-- 8. APPLY MASKING POLICIES
-- =========================================================

ALTER TABLE CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
MODIFY COLUMN user_id
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_USER_ID;

ALTER TABLE CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
MODIFY COLUMN city
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_CITY;

ALTER TABLE CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
MODIFY COLUMN income_level
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_INCOME_LEVEL;

ALTER TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360
MODIFY COLUMN user_id
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_USER_ID;

ALTER TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360
MODIFY COLUMN city
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_CITY;

ALTER TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE
MODIFY COLUMN user_id
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_USER_ID;

ALTER TABLE SALES_DOMAIN_DB.SILVER.PAYMENTS_CLEAN
MODIFY COLUMN transaction_reference
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_TRANSACTION_REFERENCE;

ALTER TABLE SALES_DOMAIN_DB.GOLD.SALES_FACT
MODIFY COLUMN user_id
SET MASKING POLICY GOVERNANCE_DB.POLICIES.MASK_USER_ID;


-- =========================================================
-- 9. ROW ACCESS POLICY
-- =========================================================

CREATE OR REPLACE ROW ACCESS POLICY GOVERNANCE_DB.POLICIES.COUNTRY_ROW_ACCESS_POLICY
AS (country STRING) RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN (
            'ACCOUNTADMIN',
            'DATAMESH_ADMIN_ROLE',
            'DATA_STEWARD_ROLE'
        )
        THEN TRUE
        WHEN CURRENT_ROLE() = 'CUSTOMER_DOMAIN_OWNER_ROLE'
        THEN TRUE
        WHEN CURRENT_ROLE() = 'ANALYTICS_CONSUMER_ROLE'
        THEN country IN ('US', 'UK', 'DE', 'IN')
        ELSE FALSE
    END;


-- =========================================================
-- 10. APPLY ROW ACCESS POLICY
-- =========================================================

ALTER TABLE CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
ADD ROW ACCESS POLICY GOVERNANCE_DB.POLICIES.COUNTRY_ROW_ACCESS_POLICY
ON (country);

ALTER TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360
ADD ROW ACCESS POLICY GOVERNANCE_DB.POLICIES.COUNTRY_ROW_ACCESS_POLICY
ON (country);

ALTER TABLE CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE
ADD ROW ACCESS POLICY GOVERNANCE_DB.POLICIES.COUNTRY_ROW_ACCESS_POLICY
ON (country);


-- =========================================================
-- 11. SECURE CONSUMPTION VIEWS
-- =========================================================

CREATE SCHEMA IF NOT EXISTS ANALYTICS_DB.SECURE_ANALYTICS;

CREATE OR REPLACE SECURE VIEW ANALYTICS_DB.SECURE_ANALYTICS.SECURE_CUSTOMER_360 AS
SELECT
    user_id,
    age,
    gender,
    country,
    city,
    signup_date,
    income_level,
    preferred_category,
    loyalty_tier,
    total_purchases,
    total_orders,
    lifetime_revenue,
    avg_purchase_value,
    last_purchase_date,
    total_support_tickets,
    avg_satisfaction_score,
    total_sessions,
    converted_sessions
FROM CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360;

CREATE OR REPLACE SECURE VIEW ANALYTICS_DB.SECURE_ANALYTICS.SECURE_SALES_FACT AS
SELECT
    purchase_id,
    order_id,
    user_id,
    product_id,
    quantity,
    unit_price,
    total_amount,
    order_date,
    customer_country,
    loyalty_tier,
    product_name,
    category,
    subcategory,
    brand,
    payment_method,
    payment_status,
    currency_code,
    is_returned,
    is_refunded,
    refund_amount
FROM SALES_DOMAIN_DB.GOLD.SALES_FACT;

CREATE OR REPLACE SECURE VIEW ANALYTICS_DB.SECURE_ANALYTICS.SECURE_PRODUCT_PERFORMANCE AS
SELECT
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    price,
    total_purchases,
    total_units_sold,
    total_revenue,
    actual_avg_review_rating,
    total_reviews,
    total_stock_on_hand
FROM PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360;

GRANT USAGE ON SCHEMA ANALYTICS_DB.SECURE_ANALYTICS TO ROLE ANALYTICS_CONSUMER_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA ANALYTICS_DB.SECURE_ANALYTICS TO ROLE ANALYTICS_CONSUMER_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA ANALYTICS_DB.SECURE_ANALYTICS TO ROLE ANALYTICS_CONSUMER_ROLE;


-- =========================================================
-- 12. GOVERNANCE AUDIT TABLE
-- =========================================================

CREATE OR REPLACE TABLE GOVERNANCE_DB.AUDIT.DATA_PRODUCT_AUDIT AS
SELECT
    'CUSTOMER' AS domain_name,
    'CUSTOMER_360' AS data_product_name,
    'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360' AS object_name,
    CURRENT_TIMESTAMP() AS audit_ts,
    'ACTIVE' AS status
UNION ALL
SELECT 'CUSTOMER', 'CUSTOMER_LIFETIME_VALUE', 'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_LIFETIME_VALUE', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'CUSTOMER', 'CUSTOMER_SUPPORT_SUMMARY', 'CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_SUPPORT_SUMMARY', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'PRODUCT', 'PRODUCT_360', 'PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'PRODUCT', 'PRODUCT_PERFORMANCE', 'PRODUCT_DOMAIN_DB.GOLD.PRODUCT_PERFORMANCE', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'PRODUCT', 'SUPPLIER_PERFORMANCE', 'PRODUCT_DOMAIN_DB.GOLD.SUPPLIER_PERFORMANCE', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'SALES', 'SALES_FACT', 'SALES_DOMAIN_DB.GOLD.SALES_FACT', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'SALES', 'DAILY_SALES', 'SALES_DOMAIN_DB.GOLD.DAILY_SALES', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'SALES', 'MONTHLY_REVENUE', 'SALES_DOMAIN_DB.GOLD.MONTHLY_REVENUE', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'SALES', 'RETURN_ANALYTICS', 'SALES_DOMAIN_DB.GOLD.RETURN_ANALYTICS', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'INVENTORY', 'INVENTORY_STATUS', 'INVENTORY_DOMAIN_DB.GOLD.INVENTORY_STATUS', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'INVENTORY', 'STOCK_ALERTS', 'INVENTORY_DOMAIN_DB.GOLD.STOCK_ALERTS', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'INVENTORY', 'SHIPPING_PERFORMANCE', 'INVENTORY_DOMAIN_DB.GOLD.SHIPPING_PERFORMANCE', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'MARKETING', 'CAMPAIGN_ROI', 'MARKETING_DOMAIN_DB.GOLD.CAMPAIGN_ROI', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'MARKETING', 'CONVERSION_FUNNEL', 'MARKETING_DOMAIN_DB.GOLD.CONVERSION_FUNNEL', CURRENT_TIMESTAMP(), 'ACTIVE'
UNION ALL
SELECT 'MARKETING', 'USER_BEHAVIOR', 'MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR', CURRENT_TIMESTAMP(), 'ACTIVE';


-- =========================================================
-- 13. GOVERNANCE VALIDATION
-- =========================================================

SELECT
    tag_database,
    tag_schema,
    tag_name,
    tag_value,
    object_database,
    object_schema,
    object_name
FROM TABLE(
    INFORMATION_SCHEMA.TAG_REFERENCES_ALL_COLUMNS(
        'CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN',
        'TABLE'
    )
);

SELECT
    policy_name,
    policy_kind,
    ref_database_name,
    ref_schema_name,
    ref_entity_name,
    ref_column_name
FROM TABLE(
    GOVERNANCE_DB.INFORMATION_SCHEMA.POLICY_REFERENCES(
        POLICY_NAME => 'GOVERNANCE_DB.POLICIES.MASK_USER_ID'
    )
);

SELECT 'SECURE_CUSTOMER_360' AS secure_view_name, COUNT(*) AS row_count
FROM ANALYTICS_DB.SECURE_ANALYTICS.SECURE_CUSTOMER_360
UNION ALL
SELECT 'SECURE_SALES_FACT', COUNT(*)
FROM ANALYTICS_DB.SECURE_ANALYTICS.SECURE_SALES_FACT
UNION ALL
SELECT 'SECURE_PRODUCT_PERFORMANCE', COUNT(*)
FROM ANALYTICS_DB.SECURE_ANALYTICS.SECURE_PRODUCT_PERFORMANCE;

SELECT *
FROM GOVERNANCE_DB.AUDIT.DATA_PRODUCT_AUDIT
ORDER BY domain_name, data_product_name;


USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

-- =========================================================
-- PHASE 7: DATA QUALITY FRAMEWORK
-- =========================================================

CREATE DATABASE IF NOT EXISTS DATA_QUALITY_DB;
CREATE SCHEMA IF NOT EXISTS DATA_QUALITY_DB.DQ;

USE DATABASE DATA_QUALITY_DB;
USE SCHEMA DQ;

-- =========================================================
-- 1. DQ RULES TABLE
-- =========================================================

CREATE OR REPLACE TABLE DQ_RULES (
    rule_id NUMBER AUTOINCREMENT START 1 INCREMENT 1,
    domain_name STRING,
    database_name STRING,
    schema_name STRING,
    table_name STRING,
    column_name STRING,
    rule_type STRING,
    rule_description STRING,
    severity STRING,
    is_active BOOLEAN,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =========================================================
-- 2. DQ RESULTS TABLE
-- =========================================================

CREATE OR REPLACE TABLE DQ_RESULTS (
    run_id STRING,
    run_ts TIMESTAMP_NTZ,
    domain_name STRING,
    database_name STRING,
    schema_name STRING,
    table_name STRING,
    column_name STRING,
    rule_type STRING,
    rule_description STRING,
    severity STRING,
    failed_record_count NUMBER,
    total_record_count NUMBER,
    pass_rate NUMBER(10,4),
    dq_status STRING
);

-- =========================================================
-- 3. INSERT DQ RULES
-- =========================================================

INSERT INTO DQ_RULES (
    domain_name, database_name, schema_name, table_name,
    column_name, rule_type, rule_description, severity, is_active
)
VALUES
('CUSTOMER','CUSTOMER_DOMAIN_DB','SILVER','CUSTOMERS_CLEAN','USER_ID','NOT_NULL','Customer ID must not be null','CRITICAL',TRUE),
('CUSTOMER','CUSTOMER_DOMAIN_DB','SILVER','CUSTOMERS_CLEAN','USER_ID','UNIQUE','Customer ID must be unique','CRITICAL',TRUE),
('CUSTOMER','CUSTOMER_DOMAIN_DB','SILVER','CUSTOMERS_CLEAN','AGE','RANGE','Age must be between 13 and 100','HIGH',TRUE),
('CUSTOMER','CUSTOMER_DOMAIN_DB','SILVER','CUSTOMERS_CLEAN','SIGNUP_DATE','VALID_DATE','Signup date must not be in the future','MEDIUM',TRUE),

('PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','PRODUCT_ID','NOT_NULL','Product ID must not be null','CRITICAL',TRUE),
('PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','PRODUCT_ID','UNIQUE','Product ID must be unique','CRITICAL',TRUE),
('PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','PRICE','NON_NEGATIVE','Product price must not be negative','HIGH',TRUE),
('PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','RATING_AVG','RANGE','Rating must be between 0 and 5','MEDIUM',TRUE),

('SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','PURCHASE_ID','NOT_NULL','Purchase ID must not be null','CRITICAL',TRUE),
('SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','PURCHASE_ID','UNIQUE','Purchase ID must be unique','CRITICAL',TRUE),
('SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','USER_ID','REFERENTIAL_INTEGRITY','Purchase user must exist in customer domain','CRITICAL',TRUE),
('SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','PRODUCT_ID','REFERENTIAL_INTEGRITY','Purchase product must exist in product domain','CRITICAL',TRUE),
('SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','QUANTITY','POSITIVE','Purchase quantity must be positive','HIGH',TRUE),
('SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','TOTAL_AMOUNT','NON_NEGATIVE','Purchase total amount must not be negative','HIGH',TRUE),

('INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','INVENTORY_ID','NOT_NULL','Inventory ID must not be null','CRITICAL',TRUE),
('INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','PRODUCT_ID','REFERENTIAL_INTEGRITY','Inventory product must exist in product domain','CRITICAL',TRUE),
('INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','STOCK_ON_HAND','NON_NEGATIVE','Stock on hand must not be negative','HIGH',TRUE),
('INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','RESERVED_QUANTITY','NON_NEGATIVE','Reserved quantity must not be negative','HIGH',TRUE),

('MARKETING','MARKETING_DOMAIN_DB','SILVER','SESSIONS_CLEAN','SESSION_ID','NOT_NULL','Session ID must not be null','CRITICAL',TRUE),
('MARKETING','MARKETING_DOMAIN_DB','SILVER','SESSIONS_CLEAN','SESSION_ID','UNIQUE','Session ID must be unique','CRITICAL',TRUE),
('MARKETING','MARKETING_DOMAIN_DB','SILVER','SESSIONS_CLEAN','USER_ID','REFERENTIAL_INTEGRITY','Session user must exist in customer domain','HIGH',TRUE);

-- =========================================================
-- 4. RUN DQ CHECKS
-- =========================================================
SET RUN_ID = 'DQ_RUN_001';

-- CUSTOMER NOT NULL
INSERT INTO DQ_RESULTS
SELECT
    $RUN_ID,
    CURRENT_TIMESTAMP(),
    'CUSTOMER',
    'CUSTOMER_DOMAIN_DB',
    'SILVER',
    'CUSTOMERS_CLEAN',
    'USER_ID',
    'NOT_NULL',
    'Customer ID must not be null',
    'CRITICAL',
    COUNT_IF(user_id IS NULL),
    COUNT(*),
    1 - COUNT_IF(user_id IS NULL) / NULLIF(COUNT(*), 0),
    CASE WHEN COUNT_IF(user_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN;

-- CUSTOMER UNIQUE
INSERT INTO DQ_RESULTS
SELECT
    $RUN_ID,
    CURRENT_TIMESTAMP(),
    'CUSTOMER',
    'CUSTOMER_DOMAIN_DB',
    'SILVER',
    'CUSTOMERS_CLEAN',
    'USER_ID',
    'UNIQUE',
    'Customer ID must be unique',
    'CRITICAL',
    COUNT(*),
    (SELECT COUNT(*) FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN),
    1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN), 0),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT user_id
    FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN
    GROUP BY user_id
    HAVING COUNT(*) > 1
);

-- CUSTOMER AGE RANGE
INSERT INTO DQ_RESULTS
SELECT
    $RUN_ID,
    CURRENT_TIMESTAMP(),
    'CUSTOMER',
    'CUSTOMER_DOMAIN_DB',
    'SILVER',
    'CUSTOMERS_CLEAN',
    'AGE',
    'RANGE',
    'Age must be between 13 and 100',
    'HIGH',
    COUNT_IF(age < 13 OR age > 100 OR age IS NULL),
    COUNT(*),
    1 - COUNT_IF(age < 13 OR age > 100 OR age IS NULL) / NULLIF(COUNT(*), 0),
    CASE WHEN COUNT_IF(age < 13 OR age > 100 OR age IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN;

-- CUSTOMER SIGNUP DATE
INSERT INTO DQ_RESULTS
SELECT
    $RUN_ID,
    CURRENT_TIMESTAMP(),
    'CUSTOMER',
    'CUSTOMER_DOMAIN_DB',
    'SILVER',
    'CUSTOMERS_CLEAN',
    'SIGNUP_DATE',
    'VALID_DATE',
    'Signup date must not be in the future',
    'MEDIUM',
    COUNT_IF(signup_date > CURRENT_DATE()),
    COUNT(*),
    1 - COUNT_IF(signup_date > CURRENT_DATE()) / NULLIF(COUNT(*), 0),
    CASE WHEN COUNT_IF(signup_date > CURRENT_DATE()) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN;

-- PRODUCT CHECKS
INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','PRODUCT_ID','NOT_NULL',
'Product ID must not be null','CRITICAL',
COUNT_IF(product_id IS NULL), COUNT(*),
1 - COUNT_IF(product_id IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(product_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','PRODUCT_ID','UNIQUE',
'Product ID must be unique','CRITICAL',
COUNT(*),
(SELECT COUNT(*) FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN),
1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN), 0),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT product_id
    FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN
    GROUP BY product_id
    HAVING COUNT(*) > 1
);

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','PRICE','NON_NEGATIVE',
'Product price must not be negative','HIGH',
COUNT_IF(price < 0 OR price IS NULL), COUNT(*),
1 - COUNT_IF(price < 0 OR price IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(price < 0 OR price IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'PRODUCT','PRODUCT_DOMAIN_DB','SILVER','PRODUCTS_CLEAN','RATING_AVG','RANGE',
'Rating must be between 0 and 5','MEDIUM',
COUNT_IF(rating_avg < 0 OR rating_avg > 5), COUNT(*),
1 - COUNT_IF(rating_avg < 0 OR rating_avg > 5) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(rating_avg < 0 OR rating_avg > 5) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN;

-- SALES CHECKS
INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','PURCHASE_ID','NOT_NULL',
'Purchase ID must not be null','CRITICAL',
COUNT_IF(purchase_id IS NULL), COUNT(*),
1 - COUNT_IF(purchase_id IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(purchase_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','PURCHASE_ID','UNIQUE',
'Purchase ID must be unique','CRITICAL',
COUNT(*),
(SELECT COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN),
1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN), 0),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT purchase_id
    FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN
    GROUP BY purchase_id
    HAVING COUNT(*) > 1
);

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','USER_ID','REFERENTIAL_INTEGRITY',
'Purchase user must exist in customer domain','CRITICAL',
COUNT(*),
(SELECT COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN),
1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN), 0),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
LEFT JOIN CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN c
    ON p.user_id = c.user_id
WHERE c.user_id IS NULL;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','PRODUCT_ID','REFERENTIAL_INTEGRITY',
'Purchase product must exist in product domain','CRITICAL',
COUNT(*),
(SELECT COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN),
1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN), 0),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN p
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN pr
    ON p.product_id = pr.product_id
WHERE pr.product_id IS NULL;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','QUANTITY','POSITIVE',
'Purchase quantity must be positive','HIGH',
COUNT_IF(quantity <= 0 OR quantity IS NULL), COUNT(*),
1 - COUNT_IF(quantity <= 0 OR quantity IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(quantity <= 0 OR quantity IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'SALES','SALES_DOMAIN_DB','SILVER','PURCHASES_CLEAN','TOTAL_AMOUNT','NON_NEGATIVE',
'Purchase total amount must not be negative','HIGH',
COUNT_IF(total_amount < 0 OR total_amount IS NULL), COUNT(*),
1 - COUNT_IF(total_amount < 0 OR total_amount IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(total_amount < 0 OR total_amount IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM SALES_DOMAIN_DB.SILVER.PURCHASES_CLEAN;

-- INVENTORY CHECKS
INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','INVENTORY_ID','NOT_NULL',
'Inventory ID must not be null','CRITICAL',
COUNT_IF(inventory_id IS NULL), COUNT(*),
1 - COUNT_IF(inventory_id IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(inventory_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','PRODUCT_ID','REFERENTIAL_INTEGRITY',
'Inventory product must exist in product domain','CRITICAL',
COUNT(*),
(SELECT COUNT(*) FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN),
1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN), 0),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN i
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','STOCK_ON_HAND','NON_NEGATIVE',
'Stock on hand must not be negative','HIGH',
COUNT_IF(stock_on_hand < 0 OR stock_on_hand IS NULL), COUNT(*),
1 - COUNT_IF(stock_on_hand < 0 OR stock_on_hand IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(stock_on_hand < 0 OR stock_on_hand IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'INVENTORY','INVENTORY_DOMAIN_DB','SILVER','INVENTORY_CLEAN','RESERVED_QUANTITY','NON_NEGATIVE',
'Reserved quantity must not be negative','HIGH',
COUNT_IF(reserved_quantity < 0 OR reserved_quantity IS NULL), COUNT(*),
1 - COUNT_IF(reserved_quantity < 0 OR reserved_quantity IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(reserved_quantity < 0 OR reserved_quantity IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM INVENTORY_DOMAIN_DB.SILVER.INVENTORY_CLEAN;

-- MARKETING CHECKS
INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'MARKETING','MARKETING_DOMAIN_DB','SILVER','SESSIONS_CLEAN','SESSION_ID','NOT_NULL',
'Session ID must not be null','CRITICAL',
COUNT_IF(session_id IS NULL), COUNT(*),
1 - COUNT_IF(session_id IS NULL) / NULLIF(COUNT(*), 0),
CASE WHEN COUNT_IF(session_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN;

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'MARKETING','MARKETING_DOMAIN_DB','SILVER','SESSIONS_CLEAN','SESSION_ID','UNIQUE',
'Session ID must be unique','CRITICAL',
COUNT(*),
(SELECT COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN),
1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN), 0),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT session_id
    FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN
    GROUP BY session_id
    HAVING COUNT(*) > 1
);

INSERT INTO DQ_RESULTS
SELECT $RUN_ID, CURRENT_TIMESTAMP(), 'MARKETING','MARKETING_DOMAIN_DB','SILVER','SESSIONS_CLEAN','USER_ID','REFERENTIAL_INTEGRITY',
'Session user must exist in customer domain','HIGH',
COUNT(*),
(SELECT COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN),
1 - COUNT(*) / NULLIF((SELECT COUNT(*) FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN), 0),
CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM MARKETING_DOMAIN_DB.SILVER.SESSIONS_CLEAN s
LEFT JOIN CUSTOMER_DOMAIN_DB.SILVER.CUSTOMERS_CLEAN c
    ON s.user_id = c.user_id
WHERE c.user_id IS NULL;

-- =========================================================
-- 5. DQ SCORECARD VIEWS
-- =========================================================

CREATE OR REPLACE VIEW DQ_LATEST_RESULTS AS
SELECT *
FROM DQ_RESULTS
QUALIFY run_ts = MAX(run_ts) OVER ();

CREATE OR REPLACE VIEW DQ_DOMAIN_SCORECARD AS
SELECT
    domain_name,
    COUNT(*) AS total_rules,
    COUNT_IF(dq_status = 'PASS') AS passed_rules,
    COUNT_IF(dq_status = 'FAIL') AS failed_rules,
    ROUND(AVG(pass_rate) * 100, 2) AS avg_pass_rate_percent,
    CASE
        WHEN COUNT_IF(severity = 'CRITICAL' AND dq_status = 'FAIL') > 0 THEN 'CRITICAL_FAILURE'
        WHEN COUNT_IF(dq_status = 'FAIL') > 0 THEN 'WARNING'
        ELSE 'HEALTHY'
    END AS domain_dq_status
FROM DQ_LATEST_RESULTS
GROUP BY domain_name;

CREATE OR REPLACE VIEW DQ_RULE_FAILURES AS
SELECT
    run_id,
    run_ts,
    domain_name,
    database_name,
    schema_name,
    table_name,
    column_name,
    rule_type,
    rule_description,
    severity,
    failed_record_count,
    total_record_count,
    ROUND(pass_rate * 100, 2) AS pass_rate_percent,
    dq_status
FROM DQ_LATEST_RESULTS
WHERE dq_status = 'FAIL';

CREATE OR REPLACE VIEW DQ_ENTERPRISE_SCORECARD AS
SELECT
    COUNT(*) AS total_rules,
    COUNT_IF(dq_status = 'PASS') AS passed_rules,
    COUNT_IF(dq_status = 'FAIL') AS failed_rules,
    ROUND(AVG(pass_rate) * 100, 2) AS enterprise_pass_rate_percent,
    CASE
        WHEN COUNT_IF(severity = 'CRITICAL' AND dq_status = 'FAIL') > 0 THEN 'CRITICAL_FAILURE'
        WHEN COUNT_IF(dq_status = 'FAIL') > 0 THEN 'WARNING'
        ELSE 'HEALTHY'
    END AS enterprise_dq_status
FROM DQ_LATEST_RESULTS;

-- =========================================================
-- 6. VALIDATION
-- =========================================================

SELECT * FROM DQ_ENTERPRISE_SCORECARD;

SELECT * FROM DQ_DOMAIN_SCORECARD
ORDER BY domain_name;

SELECT * FROM DQ_RULE_FAILURES
ORDER BY severity, domain_name, table_name;


USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

CREATE DATABASE IF NOT EXISTS AI_DATA_PRODUCTS_DB;
CREATE SCHEMA IF NOT EXISTS AI_DATA_PRODUCTS_DB.CORTEX_AI;

USE DATABASE AI_DATA_PRODUCTS_DB;
USE SCHEMA CORTEX_AI;

-- =====================================================
-- FALLBACK 1: REVIEW SENTIMENT WITHOUT CORTEX
-- =====================================================

CREATE OR REPLACE TABLE PRODUCT_REVIEW_SENTIMENT AS
SELECT
    r.review_id,
    r.user_id,
    r.product_id,
    p.product_name,
    p.category,
    p.brand,
    r.rating,
    r.title,
    r.review_text,
    r.review_date,

    CASE
        WHEN r.rating >= 4 THEN 0.75
        WHEN r.rating = 3 THEN 0
        WHEN r.rating <= 2 THEN -0.75
        ELSE 0
    END AS sentiment_score,

    CASE
        WHEN r.rating >= 4 THEN 'positive'
        WHEN r.rating = 3 THEN 'neutral'
        WHEN r.rating <= 2 THEN 'negative'
        ELSE 'unknown'
    END AS sentiment_label,

    'SQL_RULE_BASED_FALLBACK' AS ai_method,
    CURRENT_TIMESTAMP() AS ai_created_at
FROM PRODUCT_DOMAIN_DB.SILVER.REVIEWS_CLEAN r
LEFT JOIN PRODUCT_DOMAIN_DB.SILVER.PRODUCTS_CLEAN p
    ON r.product_id = p.product_id;

-- =====================================================
-- FALLBACK 2: PRODUCT REVIEW SUMMARY
-- =====================================================

CREATE OR REPLACE TABLE PRODUCT_REVIEW_SUMMARY AS
SELECT
    product_id,
    product_name,
    category,
    brand,
    COUNT(*) AS review_count,
    AVG(rating) AS avg_rating,
    AVG(sentiment_score) AS avg_sentiment_score,
    COUNT_IF(sentiment_label = 'positive') AS positive_reviews,
    COUNT_IF(sentiment_label = 'neutral') AS neutral_reviews,
    COUNT_IF(sentiment_label = 'negative') AS negative_reviews,

    CASE
        WHEN AVG(sentiment_score) >= 0.4 THEN 'Customers are generally positive about this product.'
        WHEN AVG(sentiment_score) <= -0.4 THEN 'Customers are generally negative about this product.'
        ELSE 'Customer sentiment is mixed or neutral for this product.'
    END AS ai_review_summary,

    'SQL_RULE_BASED_FALLBACK' AS ai_method,
    CURRENT_TIMESTAMP() AS ai_created_at
FROM PRODUCT_REVIEW_SENTIMENT
GROUP BY product_id, product_name, category, brand;

-- =====================================================
-- FALLBACK 3: SUPPORT TICKET AI SUMMARY
-- =====================================================

CREATE OR REPLACE TABLE SUPPORT_TICKET_AI_SUMMARY AS
SELECT
    ticket_id,
    user_id,
    order_id,
    product_id,
    created_ts,
    closed_ts,
    ticket_channel,
    ticket_category,
    priority,
    ticket_status,
    subject,
    satisfaction_score,

    CASE
        WHEN priority = 'high' THEN 'High priority customer support issue.'
        WHEN ticket_status = 'closed' THEN 'Resolved customer support ticket.'
        ELSE 'Open or standard customer support ticket.'
    END AS ai_ticket_summary,

    CASE
        WHEN satisfaction_score >= 4 THEN 'positive'
        WHEN satisfaction_score = 3 THEN 'neutral'
        WHEN satisfaction_score <= 2 THEN 'negative'
        ELSE 'unknown'
    END AS ticket_sentiment_label,

    'SQL_RULE_BASED_FALLBACK' AS ai_method,
    CURRENT_TIMESTAMP() AS ai_created_at
FROM CUSTOMER_DOMAIN_DB.SILVER.SUPPORT_TICKETS_CLEAN;

-- =====================================================
-- FALLBACK 4: CUSTOMER EXPERIENCE PROFILE
-- =====================================================

CREATE OR REPLACE TABLE CUSTOMER_AI_EXPERIENCE_PROFILE AS
SELECT
    user_id,
    country,
    city,
    loyalty_tier,
    total_purchases,
    lifetime_revenue,
    avg_purchase_value,
    total_support_tickets,
    avg_satisfaction_score,
    total_sessions,
    converted_sessions,

    CASE
        WHEN lifetime_revenue >= 5000 AND avg_satisfaction_score >= 4 THEN 'VIP happy customer'
        WHEN lifetime_revenue >= 5000 AND avg_satisfaction_score < 4 THEN 'VIP at-risk customer'
        WHEN total_support_tickets >= 3 THEN 'support-heavy customer'
        WHEN converted_sessions = 0 THEN 'low engagement customer'
        ELSE 'standard customer'
    END AS ai_customer_segment,

    'SQL_RULE_BASED_FALLBACK' AS ai_method,
    CURRENT_TIMESTAMP() AS ai_created_at
FROM CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360;

-- =====================================================
-- FALLBACK 5: CAMPAIGN AI INSIGHTS
-- =====================================================

CREATE OR REPLACE TABLE CAMPAIGN_AI_INSIGHTS AS
SELECT
    campaign_id,
    campaign_name,
    channel,
    objective,
    campaign_status,
    target_country,
    sessions,
    conversions,
    spend_amount,
    impressions,
    clicks,
    click_through_rate,
    conversion_rate,
    cost_per_conversion,

    CASE
        WHEN conversion_rate >= 0.10 THEN 'Strong campaign conversion performance.'
        WHEN conversion_rate >= 0.03 THEN 'Moderate campaign conversion performance.'
        ELSE 'Low campaign conversion performance; optimization recommended.'
    END AS ai_campaign_summary,

    'SQL_RULE_BASED_FALLBACK' AS ai_method,
    CURRENT_TIMESTAMP() AS ai_created_at
FROM MARKETING_DOMAIN_DB.GOLD.CAMPAIGN_ROI;

-- =====================================================
-- FALLBACK 6: PRODUCT RECOMMENDATION FEATURES
-- =====================================================

CREATE OR REPLACE TABLE AI_PRODUCT_RECOMMENDATION_FEATURES AS
SELECT
    c.user_id,
    c.country,
    c.city,
    c.loyalty_tier,
    c.preferred_category,
    c.lifetime_revenue,
    ub.total_sessions,
    ub.unique_products_viewed,
    ub.avg_dwell_time_ms,
    ub.revenue AS behavior_revenue,
    p.category AS purchased_category,
    p.brand AS purchased_brand,
    COUNT(DISTINCT sf.product_id) AS products_purchased,
    SUM(sf.total_amount) AS category_revenue,
    'SQL_RULE_BASED_FALLBACK' AS ai_method,
    CURRENT_TIMESTAMP() AS ai_created_at
FROM CUSTOMER_DOMAIN_DB.GOLD.CUSTOMER_360 c
LEFT JOIN MARKETING_DOMAIN_DB.GOLD.USER_BEHAVIOR ub
    ON c.user_id = ub.user_id
LEFT JOIN SALES_DOMAIN_DB.GOLD.SALES_FACT sf
    ON c.user_id = sf.user_id
LEFT JOIN PRODUCT_DOMAIN_DB.GOLD.PRODUCT_360 p
    ON sf.product_id = p.product_id
GROUP BY
    c.user_id,
    c.country,
    c.city,
    c.loyalty_tier,
    c.preferred_category,
    c.lifetime_revenue,
    ub.total_sessions,
    ub.unique_products_viewed,
    ub.avg_dwell_time_ms,
    ub.revenue,
    p.category,
    p.brand;

-- =====================================================
-- VALIDATION
-- =====================================================

SELECT 'PRODUCT_REVIEW_SENTIMENT' AS ai_object_name, COUNT(*) AS row_count FROM PRODUCT_REVIEW_SENTIMENT
UNION ALL
SELECT 'PRODUCT_REVIEW_SUMMARY', COUNT(*) FROM PRODUCT_REVIEW_SUMMARY
UNION ALL
SELECT 'SUPPORT_TICKET_AI_SUMMARY', COUNT(*) FROM SUPPORT_TICKET_AI_SUMMARY
UNION ALL
SELECT 'CUSTOMER_AI_EXPERIENCE_PROFILE', COUNT(*) FROM CUSTOMER_AI_EXPERIENCE_PROFILE
UNION ALL
SELECT 'CAMPAIGN_AI_INSIGHTS', COUNT(*) FROM CAMPAIGN_AI_INSIGHTS
UNION ALL
SELECT 'AI_PRODUCT_RECOMMENDATION_FEATURES', COUNT(*) FROM AI_PRODUCT_RECOMMENDATION_FEATURES
ORDER BY ai_object_name;

SELECT CURRENT_USER();

USE ROLE ACCOUNTADMIN;

ALTER USER <YOUR_SNOWFLAKE_USER>
SET RSA_PUBLIC_KEY='<YOUR_RSA_PUBLIC_KEY_BODY>';

DESC USER <YOUR_SNOWFLAKE_USER>;

SELECT CURRENT_ORGANIZATION_NAME(), CURRENT_ACCOUNT_NAME();

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS DATA_QUALITY_DB;
CREATE SCHEMA IF NOT EXISTS DATA_QUALITY_DB.DQ;

GRANT USAGE ON DATABASE DATA_QUALITY_DB TO ROLE ACCOUNTADMIN;
GRANT USAGE ON SCHEMA DATA_QUALITY_DB.DQ TO ROLE ACCOUNTADMIN;


USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

CREATE DATABASE IF NOT EXISTS ANALYTICS_DB;
CREATE SCHEMA IF NOT EXISTS ANALYTICS_DB.PRESENTATION;

USE DATABASE ANALYTICS_DB;
USE SCHEMA PRESENTATION;

-- =========================================================
-- 1. EXECUTIVE KPI VIEW
-- =========================================================

CREATE OR REPLACE VIEW EXECUTIVE_KPI AS
SELECT
    COALESCE(SUM(gross_revenue), 0) AS total_revenue,
    COALESCE(SUM(net_revenue), 0) AS net_revenue,
    COALESCE(SUM(total_orders), 0) AS total_orders,
    COALESCE(SUM(total_purchases), 0) AS total_purchases,
    COALESCE(SUM(unique_customers), 0) AS total_customers,
    COALESCE(SUM(total_units_sold), 0) AS total_units_sold,
    COALESCE(AVG(avg_purchase_value), 0) AS avg_order_value,
    COALESCE(SUM(returned_revenue), 0) AS returned_revenue,
    COALESCE(SUM(refunded_amount), 0) AS refunded_amount,
    CURRENT_TIMESTAMP() AS refreshed_at
FROM ANALYTICS_DB.RETAIL_ANALYTICS.EXECUTIVE_REVENUE_DASHBOARD;


-- =========================================================
-- 2. REVENUE TREND
-- =========================================================

CREATE OR REPLACE VIEW REVENUE_TREND AS
SELECT
    revenue_month,
    SUM(gross_revenue) AS gross_revenue,
    SUM(net_revenue) AS net_revenue,
    SUM(total_orders) AS total_orders,
    SUM(unique_customers) AS unique_customers,
    AVG(avg_purchase_value) AS avg_purchase_value
FROM ANALYTICS_DB.RETAIL_ANALYTICS.EXECUTIVE_REVENUE_DASHBOARD
GROUP BY revenue_month
ORDER BY revenue_month;


-- =========================================================
-- 3. SALES BY COUNTRY CATEGORY MONTH
-- =========================================================

CREATE OR REPLACE VIEW SALES_COUNTRY_CATEGORY AS
SELECT
    sales_month,
    customer_country,
    category,
    subcategory,
    brand,
    total_orders,
    total_purchases,
    unique_customers,
    total_units_sold,
    gross_revenue,
    returned_revenue,
    refunded_amount,
    net_revenue
FROM ANALYTICS_DB.RETAIL_ANALYTICS.SALES_BY_COUNTRY_CATEGORY_MONTH;


-- =========================================================
-- 4. CUSTOMER OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW CUSTOMER_OVERVIEW AS
SELECT
    user_id,
    age,
    gender,
    country,
    city,
    income_level,
    preferred_category,
    loyalty_tier,
    total_purchases,
    total_orders,
    lifetime_revenue,
    avg_purchase_value,
    last_purchase_date,
    customer_value_segment,
    total_support_tickets,
    avg_satisfaction_score,
    total_sessions,
    converted_sessions,
    customer_conversion_rate
FROM ANALYTICS_DB.RETAIL_ANALYTICS.CUSTOMER_360_ANALYTICS;


-- =========================================================
-- 5. CUSTOMER KPI
-- =========================================================

CREATE OR REPLACE VIEW CUSTOMER_KPI AS
SELECT
    COUNT(DISTINCT user_id) AS total_customers,
    COUNT_IF(customer_value_segment = 'high_value') AS high_value_customers,
    COUNT_IF(customer_value_segment = 'medium_value') AS medium_value_customers,
    COUNT_IF(customer_value_segment = 'low_value') AS low_value_customers,
    AVG(lifetime_revenue) AS avg_customer_lifetime_value,
    AVG(avg_satisfaction_score) AS avg_satisfaction_score,
    AVG(customer_conversion_rate) AS avg_conversion_rate
FROM CUSTOMER_OVERVIEW;


-- =========================================================
-- 6. PRODUCT OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW PRODUCT_OVERVIEW AS
SELECT
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    price,
    rating_avg,
    total_purchases,
    total_units_sold,
    total_revenue,
    actual_avg_review_rating,
    total_reviews,
    total_stock_on_hand,
    total_reserved_quantity,
    return_count,
    return_rate,
    performance_segment,
    product_stock_status
FROM ANALYTICS_DB.RETAIL_ANALYTICS.PRODUCT_PERFORMANCE_ANALYTICS;


-- =========================================================
-- 7. PRODUCT KPI
-- =========================================================

CREATE OR REPLACE VIEW PRODUCT_KPI AS
SELECT
    COUNT(DISTINCT product_id) AS total_products,
    COUNT_IF(performance_segment = 'top_performer') AS top_performers,
    COUNT_IF(performance_segment = 'mid_performer') AS mid_performers,
    COUNT_IF(performance_segment = 'low_performer') AS low_performers,
    SUM(total_revenue) AS product_revenue,
    SUM(total_units_sold) AS total_units_sold,
    AVG(return_rate) AS avg_return_rate,
    AVG(actual_avg_review_rating) AS avg_review_rating
FROM PRODUCT_OVERVIEW;


-- =========================================================
-- 8. SALES OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW SALES_OVERVIEW AS
SELECT
    purchase_id,
    order_id,
    user_id,
    product_id,
    quantity,
    unit_price,
    total_amount,
    order_date,
    customer_country,
    customer_city,
    loyalty_tier,
    product_name,
    category,
    subcategory,
    brand,
    payment_method,
    payment_status,
    currency_code,
    fraud_score,
    is_returned,
    return_reason,
    return_status,
    is_refunded,
    refund_amount
FROM SALES_DOMAIN_DB.GOLD.SALES_FACT;


-- =========================================================
-- 9. RETURNS REFUNDS OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW RETURNS_REFUNDS_OVERVIEW AS
SELECT
    return_id,
    order_id,
    purchase_id,
    user_id,
    product_id,
    return_ts,
    return_reason,
    return_status,
    quantity_returned,
    condition_received,
    original_purchase_amount,
    refund_amount,
    refund_status,
    refund_method,
    category,
    brand,
    refund_ratio
FROM ANALYTICS_DB.RETAIL_ANALYTICS.RETURNS_REFUNDS_ANALYTICS;


-- =========================================================
-- 10. INVENTORY OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW INVENTORY_OVERVIEW AS
SELECT
    product_id,
    product_name,
    category,
    brand,
    warehouse_id,
    warehouse_name,
    country,
    city,
    stock_on_hand,
    reserved_quantity,
    available_stock,
    reorder_point,
    reorder_quantity,
    stock_health_status,
    total_units_sold,
    total_revenue,
    inventory_risk_level
FROM ANALYTICS_DB.RETAIL_ANALYTICS.INVENTORY_RISK_DASHBOARD;


-- =========================================================
-- 11. STOCK ALERTS
-- =========================================================

CREATE OR REPLACE VIEW STOCK_ALERTS_OVERVIEW AS
SELECT
    inventory_id,
    product_id,
    product_name,
    category,
    brand,
    warehouse_id,
    warehouse_name,
    country,
    city,
    stock_on_hand,
    reserved_quantity,
    available_stock,
    reorder_point,
    reorder_quantity,
    stock_health_status,
    alert_type
FROM INVENTORY_DOMAIN_DB.GOLD.STOCK_ALERTS;


-- =========================================================
-- 12. MARKETING OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW MARKETING_OVERVIEW AS
SELECT
    campaign_id,
    campaign_name,
    channel,
    objective,
    start_date,
    end_date,
    budget_amount,
    spend_amount,
    currency_code,
    target_country,
    campaign_status,
    sessions,
    conversions,
    impressions,
    clicks,
    click_through_rate,
    conversion_rate,
    cost_per_conversion,
    budget_efficiency_ratio
FROM ANALYTICS_DB.RETAIL_ANALYTICS.CAMPAIGN_ROI_ANALYTICS;


-- =========================================================
-- 13. MARKETING ATTRIBUTION
-- =========================================================

CREATE OR REPLACE VIEW MARKETING_ATTRIBUTION_OVERVIEW AS
SELECT
    referrer_source,
    device_type,
    total_sessions,
    converted_sessions,
    total_interactions,
    total_purchases,
    attributed_revenue,
    session_conversion_rate,
    revenue_per_purchase,
    revenue_per_session
FROM ANALYTICS_DB.RETAIL_ANALYTICS.MARKETING_ATTRIBUTION_ANALYTICS;


-- =========================================================
-- 14. DATA QUALITY OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW DQ_OVERVIEW AS
SELECT *
FROM DATA_QUALITY_DB.DQ.DQ_SUMMARY;


CREATE OR REPLACE VIEW DQ_DOMAIN_OVERVIEW AS
SELECT
    domain_name,
    total_rules,
    passed_rules,
    failed_rules,
    avg_pass_rate_percent,
    domain_dq_status
FROM DATA_QUALITY_DB.DQ.DQ_DOMAIN_SCORECARD;


CREATE OR REPLACE VIEW DQ_FAILURES_OVERVIEW AS
SELECT
    run_id,
    run_ts,
    domain_name,
    database_name,
    schema_name,
    table_name,
    column_name,
    rule_type,
    rule_description,
    severity,
    failed_record_count,
    total_record_count,
    pass_rate_percent,
    dq_status
FROM DATA_QUALITY_DB.DQ.DQ_RULE_FAILURES;


-- =========================================================
-- 15. AI / FALLBACK AI OVERVIEW
-- =========================================================

CREATE OR REPLACE VIEW ANALYTICS_DB.PRESENTATION.AI_REVIEW_SENTIMENT AS
SELECT
    review_id,
    user_id,
    product_id,
    product_name,
    category,
    brand,
    rating,
    title,
    review_text,
    review_date,
    sentiment_score,
    sentiment_label
FROM AI_DATA_PRODUCTS_DB.CORTEX_AI.PRODUCT_REVIEW_SENTIMENT;


CREATE OR REPLACE VIEW AI_CUSTOMER_PROFILE AS
SELECT
    user_id,
    country,
    city,
    loyalty_tier,
    total_purchases,
    lifetime_revenue,
    avg_purchase_value,
    total_support_tickets,
    avg_satisfaction_score,
    total_sessions,
    converted_sessions,
    ai_customer_segment,
    ai_method,
    ai_created_at
FROM AI_DATA_PRODUCTS_DB.CORTEX_AI.CUSTOMER_AI_EXPERIENCE_PROFILE;

CREATE OR REPLACE VIEW ANALYTICS_DB.PRESENTATION.AI_CUSTOMER_PROFILE AS
SELECT *
FROM AI_DATA_PRODUCTS_DB.CORTEX_AI.CUSTOMER_AI_EXPERIENCE_PROFILE;

CREATE OR REPLACE VIEW AI_CAMPAIGN_INSIGHTS AS
SELECT
    campaign_id,
    campaign_name,
    channel,
    objective,
    campaign_status,
    target_country,
    sessions,
    conversions,
    spend_amount,
    impressions,
    clicks,
    click_through_rate,
    conversion_rate,
    cost_per_conversion,
    ai_campaign_summary,
    ai_method,
    ai_created_at
FROM AI_DATA_PRODUCTS_DB.CORTEX_AI.CAMPAIGN_AI_INSIGHTS;


-- =========================================================
-- 16. ENTERPRISE SEARCH VIEWS
-- =========================================================

CREATE OR REPLACE VIEW SEARCH_CUSTOMERS AS
SELECT
    'CUSTOMER' AS source_domain,
    'CUSTOMER_OVERVIEW' AS source_object,
    user_id AS entity_id,
    'CUSTOMER' AS entity_type,
    CONCAT_WS(
        ' | ',
        user_id,
        country,
        city,
        income_level,
        preferred_category,
        loyalty_tier,
        customer_value_segment
    ) AS searchable_text,
    OBJECT_CONSTRUCT(
        'user_id', user_id,
        'country', country,
        'city', city,
        'loyalty_tier', loyalty_tier,
        'lifetime_revenue', lifetime_revenue,
        'customer_value_segment', customer_value_segment
    ) AS entity_payload
FROM CUSTOMER_OVERVIEW;


CREATE OR REPLACE VIEW SEARCH_PRODUCTS AS
SELECT
    'PRODUCT' AS source_domain,
    'PRODUCT_OVERVIEW' AS source_object,
    product_id AS entity_id,
    'PRODUCT' AS entity_type,
    CONCAT_WS(
        ' | ',
        product_id,
        product_name,
        category,
        subcategory,
        brand,
        performance_segment,
        product_stock_status
    ) AS searchable_text,
    OBJECT_CONSTRUCT(
        'product_id', product_id,
        'product_name', product_name,
        'category', category,
        'brand', brand,
        'total_revenue', total_revenue,
        'performance_segment', performance_segment
    ) AS entity_payload
FROM PRODUCT_OVERVIEW;


CREATE OR REPLACE VIEW SEARCH_SALES AS
SELECT
    'SALES' AS source_domain,
    'SALES_OVERVIEW' AS source_object,
    purchase_id AS entity_id,
    'SALE' AS entity_type,
    CONCAT_WS(
        ' | ',
        purchase_id,
        order_id,
        user_id,
        product_id,
        product_name,
        category,
        brand,
        customer_country,
        payment_status,
        return_reason
    ) AS searchable_text,
    OBJECT_CONSTRUCT(
        'purchase_id', purchase_id,
        'order_id', order_id,
        'user_id', user_id,
        'product_name', product_name,
        'total_amount', total_amount,
        'payment_status', payment_status,
        'is_returned', is_returned,
        'is_refunded', is_refunded
    ) AS entity_payload
FROM SALES_OVERVIEW;


CREATE OR REPLACE VIEW SEARCH_INVENTORY AS
SELECT
    'INVENTORY' AS source_domain,
    'INVENTORY_OVERVIEW' AS source_object,
    product_id AS entity_id,
    'INVENTORY' AS entity_type,
    CONCAT_WS(
        ' | ',
        product_id,
        product_name,
        category,
        brand,
        warehouse_id,
        warehouse_name,
        country,
        city,
        stock_health_status,
        inventory_risk_level
    ) AS searchable_text,
    OBJECT_CONSTRUCT(
        'product_id', product_id,
        'product_name', product_name,
        'warehouse_id', warehouse_id,
        'warehouse_name', warehouse_name,
        'available_stock', available_stock,
        'stock_health_status', stock_health_status,
        'inventory_risk_level', inventory_risk_level
    ) AS entity_payload
FROM INVENTORY_OVERVIEW;


CREATE OR REPLACE VIEW SEARCH_MARKETING AS
SELECT
    'MARKETING' AS source_domain,
    'MARKETING_OVERVIEW' AS source_object,
    campaign_id AS entity_id,
    'CAMPAIGN' AS entity_type,
    CONCAT_WS(
        ' | ',
        campaign_id,
        campaign_name,
        channel,
        objective,
        target_country,
        campaign_status
    ) AS searchable_text,
    OBJECT_CONSTRUCT(
        'campaign_id', campaign_id,
        'campaign_name', campaign_name,
        'channel', channel,
        'objective', objective,
        'target_country', target_country,
        'conversions', conversions,
        'conversion_rate', conversion_rate,
        'cost_per_conversion', cost_per_conversion
    ) AS entity_payload
FROM MARKETING_OVERVIEW;


CREATE OR REPLACE VIEW ENTERPRISE_SEARCH AS
SELECT * FROM SEARCH_CUSTOMERS
UNION ALL
SELECT * FROM SEARCH_PRODUCTS
UNION ALL
SELECT * FROM SEARCH_SALES
UNION ALL
SELECT * FROM SEARCH_INVENTORY
UNION ALL
SELECT * FROM SEARCH_MARKETING;


-- =========================================================
-- 17. AI COPILOT CONTEXT VIEW
-- =========================================================

CREATE OR REPLACE VIEW AI_COPILOT_CONTEXT AS
SELECT
    'EXECUTIVE' AS context_area,
    'EXECUTIVE_KPI' AS source_object,
    OBJECT_CONSTRUCT(
        'total_revenue', total_revenue,
        'net_revenue', net_revenue,
        'total_orders', total_orders,
        'total_customers', total_customers,
        'avg_order_value', avg_order_value,
        'returned_revenue', returned_revenue,
        'refunded_amount', refunded_amount
    ) AS context_payload
FROM EXECUTIVE_KPI

UNION ALL

SELECT
    'CUSTOMER',
    'CUSTOMER_KPI',
    OBJECT_CONSTRUCT(
        'total_customers', total_customers,
        'high_value_customers', high_value_customers,
        'avg_customer_lifetime_value', avg_customer_lifetime_value,
        'avg_satisfaction_score', avg_satisfaction_score,
        'avg_conversion_rate', avg_conversion_rate
    )
FROM CUSTOMER_KPI

UNION ALL

SELECT
    'PRODUCT',
    'PRODUCT_KPI',
    OBJECT_CONSTRUCT(
        'total_products', total_products,
        'top_performers', top_performers,
        'low_performers', low_performers,
        'product_revenue', product_revenue,
        'avg_return_rate', avg_return_rate,
        'avg_review_rating', avg_review_rating
    )
FROM PRODUCT_KPI

UNION ALL

SELECT
    'DATA_QUALITY' AS context_area,
    'DQ_OVERVIEW' AS source_object,
    OBJECT_CONSTRUCT(*) AS context_payload
FROM DQ_OVERVIEW;


-- =========================================================
-- 18. STREAMLIT VALIDATION
-- =========================================================

SELECT 'EXECUTIVE_KPI' AS object_name, COUNT(*) AS row_count FROM EXECUTIVE_KPI
UNION ALL SELECT 'REVENUE_TREND', COUNT(*) FROM REVENUE_TREND
UNION ALL SELECT 'SALES_COUNTRY_CATEGORY', COUNT(*) FROM SALES_COUNTRY_CATEGORY
UNION ALL SELECT 'CUSTOMER_OVERVIEW', COUNT(*) FROM CUSTOMER_OVERVIEW
UNION ALL SELECT 'CUSTOMER_KPI', COUNT(*) FROM CUSTOMER_KPI
UNION ALL SELECT 'PRODUCT_OVERVIEW', COUNT(*) FROM PRODUCT_OVERVIEW
UNION ALL SELECT 'PRODUCT_KPI', COUNT(*) FROM PRODUCT_KPI
UNION ALL SELECT 'SALES_OVERVIEW', COUNT(*) FROM SALES_OVERVIEW
UNION ALL SELECT 'RETURNS_REFUNDS_OVERVIEW', COUNT(*) FROM RETURNS_REFUNDS_OVERVIEW
UNION ALL SELECT 'INVENTORY_OVERVIEW', COUNT(*) FROM INVENTORY_OVERVIEW
UNION ALL SELECT 'STOCK_ALERTS_OVERVIEW', COUNT(*) FROM STOCK_ALERTS_OVERVIEW
UNION ALL SELECT 'MARKETING_OVERVIEW', COUNT(*) FROM MARKETING_OVERVIEW
UNION ALL SELECT 'MARKETING_ATTRIBUTION_OVERVIEW', COUNT(*) FROM MARKETING_ATTRIBUTION_OVERVIEW
UNION ALL SELECT 'DQ_OVERVIEW', COUNT(*) FROM DQ_OVERVIEW
UNION ALL SELECT 'DQ_DOMAIN_OVERVIEW', COUNT(*) FROM DQ_DOMAIN_OVERVIEW
UNION ALL SELECT 'DQ_FAILURES_OVERVIEW', COUNT(*) FROM DQ_FAILURES_OVERVIEW
UNION ALL SELECT 'AI_REVIEW_SENTIMENT', COUNT(*) FROM AI_REVIEW_SENTIMENT
UNION ALL SELECT 'AI_CUSTOMER_PROFILE', COUNT(*) FROM AI_CUSTOMER_PROFILE
UNION ALL SELECT 'AI_CAMPAIGN_INSIGHTS', COUNT(*) FROM AI_CAMPAIGN_INSIGHTS
UNION ALL SELECT 'ENTERPRISE_SEARCH', COUNT(*) FROM ENTERPRISE_SEARCH
UNION ALL SELECT 'AI_COPILOT_CONTEXT', COUNT(*) FROM AI_COPILOT_CONTEXT
ORDER BY object_name;

SHOW TABLES IN SCHEMA DATA_QUALITY_DB.DQ;

SHOW VIEWS LIKE 'DQ_SUMMARY' IN ACCOUNT;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WH_DATAMESH_XS;

CREATE OR REPLACE VIEW ANALYTICS_DB.PRESENTATION.DQ_OVERVIEW AS
SELECT *
FROM DATA_QUALITY_DB.DQ.DQ_SUMMARY;

CREATE OR REPLACE VIEW ANALYTICS_DB.PRESENTATION.DQ_DOMAIN_OVERVIEW AS
SELECT
    CAST(NULL AS STRING) AS domain_name,
    CAST(NULL AS NUMBER) AS total_rules,
    CAST(NULL AS NUMBER) AS passed_rules,
    CAST(NULL AS NUMBER) AS failed_rules,
    CAST(NULL AS NUMBER(10,2)) AS avg_pass_rate_percent,
    CAST(NULL AS STRING) AS domain_dq_status
WHERE 1 = 0;

CREATE OR REPLACE VIEW ANALYTICS_DB.PRESENTATION.DQ_FAILURES_OVERVIEW AS
SELECT
    CAST(NULL AS STRING) AS run_id,
    CAST(NULL AS TIMESTAMP_NTZ) AS run_ts,
    CAST(NULL AS STRING) AS domain_name,
    CAST(NULL AS STRING) AS database_name,
    CAST(NULL AS STRING) AS schema_name,
    CAST(NULL AS STRING) AS table_name,
    CAST(NULL AS STRING) AS column_name,
    CAST(NULL AS STRING) AS rule_type,
    CAST(NULL AS STRING) AS rule_description,
    CAST(NULL AS STRING) AS severity,
    CAST(NULL AS NUMBER) AS failed_record_count,
    CAST(NULL AS NUMBER) AS total_record_count,
    CAST(NULL AS NUMBER(10,2)) AS pass_rate_percent,
    CAST(NULL AS STRING) AS dq_status
WHERE 1 = 0;