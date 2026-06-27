resource "snowflake_warehouse" "datamesh_xs" {
  name           = "WH_DATAMESH_XS"
  warehouse_size = "XSMALL"
  auto_suspend   = 60
  auto_resume    = true

  lifecycle {
    ignore_changes = [
      enable_query_acceleration,
      query_acceleration_max_scale_factor,
      warehouse_type,
      max_cluster_count,
      min_cluster_count,
      scaling_policy,
      generation
    ]
  }
}

resource "snowflake_database" "analytics_db" {
  name = "ANALYTICS_DB"
}

resource "snowflake_database" "governance_db" {
  name = "GOVERNANCE_DB"
}

resource "snowflake_database" "data_quality_db" {
  name = "DATA_QUALITY_DB"
}