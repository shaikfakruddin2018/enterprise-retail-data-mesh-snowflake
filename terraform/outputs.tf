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

output "domain_databases" {
  description = "One database per business domain (the data mesh)."
  value       = [for d in snowflake_database.domain : d.name]
}

output "rbac_roles" {
  description = "Account roles provisioned for the platform."
  value       = values(local.roles)
}