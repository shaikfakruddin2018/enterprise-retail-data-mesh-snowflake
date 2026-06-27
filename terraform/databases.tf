# ─────────────────────────────────────────────────────────────
# Data Mesh databases — each domain owns its own database.
# These complete the mesh that main.tf starts (ANALYTICS / GOVERNANCE / DQ).
# ─────────────────────────────────────────────────────────────

locals {
  # role names (must match roles.tf) — kept as static strings so for_each
  # keys are known at plan time.
  roles = {
    admin     = "DATAMESH_ADMIN_ROLE"
    consumer  = "ANALYTICS_CONSUMER_ROLE"
    steward   = "DATA_STEWARD_ROLE"
    dbt       = "DBT_TRANSFORM_ROLE"
    streamlit = "STREAMLIT_APP_ROLE"
  }

  # one database per business domain (the heart of the mesh)
  domain_databases = {
    customer  = "CUSTOMER_DOMAIN_DB"
    product   = "PRODUCT_DOMAIN_DB"
    sales     = "SALES_DOMAIN_DB"
    inventory = "INVENTORY_DOMAIN_DB"
    marketing = "MARKETING_DOMAIN_DB"
  }

  # everything dbt builds into (mesh + shared products + raw landing)
  build_databases = concat(
    values(local.domain_databases),
    ["ANALYTICS_DB", "AI_DATA_PRODUCTS_DB", "DATAMESH_DB", "DATA_QUALITY_DB"],
  )

  # read scope for consumers
  consumer_databases = concat(values(local.domain_databases), ["ANALYTICS_DB"])
}

# domain databases
resource "snowflake_database" "domain" {
  for_each = local.domain_databases
  name     = each.value
  comment  = "Data product database for the ${each.key} domain (data mesh)."
}

# raw landing zone + AI products database
resource "snowflake_database" "datamesh_raw" {
  name    = "DATAMESH_DB"
  comment = "Raw landing zone — loaded from S3 via external stage + COPY INTO."
}

resource "snowflake_database" "ai_products" {
  name    = "AI_DATA_PRODUCTS_DB"
  comment = "Snowflake Cortex AI data products (sentiment, summaries, profiles)."
}
