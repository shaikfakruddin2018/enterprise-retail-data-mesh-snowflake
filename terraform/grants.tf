# ─────────────────────────────────────────────────────────────
# RBAC — privileges that make the 5 roles in roles.tf actually work.
# Federated governance: least-privilege per persona across the mesh.
# ─────────────────────────────────────────────────────────────

# ---- Warehouse usage for every operating role -------------------------------
resource "snowflake_grant_privileges_to_account_role" "warehouse_usage" {
  for_each = toset([
    local.roles.dbt,
    local.roles.consumer,
    local.roles.streamlit,
    local.roles.steward,
  ])
  account_role_name = each.value
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.datamesh_xs.name
  }
  depends_on = [snowflake_account_role.dbt_transform, snowflake_account_role.analytics_consumer, snowflake_account_role.streamlit_app, snowflake_account_role.data_steward]
}

# ---- DBT_TRANSFORM: build models into every data database -------------------
resource "snowflake_grant_privileges_to_account_role" "dbt_database" {
  for_each          = toset(local.build_databases)
  account_role_name = local.roles.dbt
  privileges        = ["USAGE", "CREATE SCHEMA"]
  on_account_object {
    object_type = "DATABASE"
    object_name = each.value
  }
  depends_on = [snowflake_database.domain, snowflake_database.ai_products, snowflake_database.datamesh_raw, snowflake_account_role.dbt_transform]
}

# ---- ANALYTICS_CONSUMER: read across the mesh + analytics -------------------
resource "snowflake_grant_privileges_to_account_role" "consumer_db_usage" {
  for_each          = toset(local.consumer_databases)
  account_role_name = local.roles.consumer
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = each.value
  }
  depends_on = [snowflake_database.domain, snowflake_account_role.analytics_consumer]
}

resource "snowflake_grant_privileges_to_account_role" "consumer_schema_usage" {
  for_each          = toset(local.consumer_databases)
  account_role_name = local.roles.consumer
  privileges        = ["USAGE"]
  on_schema {
    all_schemas_in_database = each.value
  }
  depends_on = [snowflake_database.domain, snowflake_account_role.analytics_consumer]
}

resource "snowflake_grant_privileges_to_account_role" "consumer_select_tables" {
  for_each          = toset(local.consumer_databases)
  account_role_name = local.roles.consumer
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = each.value
    }
  }
  depends_on = [snowflake_database.domain, snowflake_account_role.analytics_consumer]
}

resource "snowflake_grant_privileges_to_account_role" "consumer_select_views" {
  for_each          = toset(local.consumer_databases)
  account_role_name = local.roles.consumer
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = each.value
    }
  }
  depends_on = [snowflake_database.domain, snowflake_account_role.analytics_consumer]
}

# ---- STREAMLIT_APP: read-only on the curated ANALYTICS_DB -------------------
resource "snowflake_grant_privileges_to_account_role" "streamlit_db_usage" {
  account_role_name = local.roles.streamlit
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.analytics_db.name
  }
  depends_on = [snowflake_account_role.streamlit_app]
}

resource "snowflake_grant_privileges_to_account_role" "streamlit_schema_usage" {
  account_role_name = local.roles.streamlit
  privileges        = ["USAGE"]
  on_schema {
    all_schemas_in_database = snowflake_database.analytics_db.name
  }
  depends_on = [snowflake_account_role.streamlit_app]
}

resource "snowflake_grant_privileges_to_account_role" "streamlit_select_views" {
  account_role_name = local.roles.streamlit
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.analytics_db.name
    }
  }
  depends_on = [snowflake_account_role.streamlit_app]
}

# ---- DATA_STEWARD: governance — apply policies & tags ----------------------
resource "snowflake_grant_privileges_to_account_role" "steward_governance" {
  account_role_name = local.roles.steward
  privileges        = ["APPLY MASKING POLICY", "APPLY ROW ACCESS POLICY", "APPLY TAG"]
  on_account        = true
  depends_on        = [snowflake_account_role.data_steward]
}

resource "snowflake_grant_privileges_to_account_role" "steward_governance_db" {
  account_role_name = local.roles.steward
  privileges        = ["USAGE", "CREATE SCHEMA"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.governance_db.name
  }
  depends_on = [snowflake_account_role.data_steward]
}

# ---- Role hierarchy: all personas roll up to admin → SYSADMIN --------------
resource "snowflake_grant_account_role" "roles_to_admin" {
  for_each = toset([
    local.roles.dbt,
    local.roles.consumer,
    local.roles.steward,
    local.roles.streamlit,
  ])
  role_name        = each.value
  parent_role_name = local.roles.admin
  depends_on       = [snowflake_account_role.datamesh_admin, snowflake_account_role.dbt_transform, snowflake_account_role.analytics_consumer, snowflake_account_role.data_steward, snowflake_account_role.streamlit_app]
}

resource "snowflake_grant_account_role" "admin_to_sysadmin" {
  role_name        = local.roles.admin
  parent_role_name = "SYSADMIN"
  depends_on       = [snowflake_account_role.datamesh_admin]
}
