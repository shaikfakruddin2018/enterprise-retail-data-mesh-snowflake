resource "snowflake_account_role" "datamesh_admin" {
  name = "DATAMESH_ADMIN_ROLE"
}

resource "snowflake_account_role" "analytics_consumer" {
  name = "ANALYTICS_CONSUMER_ROLE"
}

resource "snowflake_account_role" "data_steward" {
  name = "DATA_STEWARD_ROLE"
}

resource "snowflake_account_role" "dbt_transform" {
  name = "DBT_TRANSFORM_ROLE"
}

resource "snowflake_account_role" "streamlit_app" {
  name = "STREAMLIT_APP_ROLE"
}