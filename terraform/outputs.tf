output "warehouse_name" {
  value = snowflake_warehouse.datamesh_xs.name
}

output "analytics_database" {
  value = snowflake_database.analytics_db.name
}

output "governance_database" {
  value = snowflake_database.governance_db.name
}

output "data_quality_database" {
  value = snowflake_database.data_quality_db.name
}