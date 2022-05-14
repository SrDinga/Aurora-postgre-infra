

output "cluster_arn" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.arn, "")
}

output "cluster_id" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.id, "")
}

output "cluster_resource_id" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.cluster_resource_id, "")
}

output "cluster_members" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.cluster_members, "")
}

output "cluster_endpoint" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.endpoint, "")
}

output "cluster_reader_endpoint" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.reader_endpoint, "")
}

output "cluster_engine_version" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.engine_version_actual, "")
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "cluster_database_name" {
  value = var.database_name
}

output "cluster_port" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.port, "")
}

output "cluster_master_password" {
  value     = try(aws_rds_cluster.aurora_postgresql_cluster.master_password, "")
  sensitive = true
}

output "cluster_master_username" {
  value     = try(aws_rds_cluster.aurora_postgresql_cluster.master_username, "")
  sensitive = true
}

output "cluster_hosted_zone_id" {
  value = try(aws_rds_cluster.aurora_postgresql_cluster.hosted_zone_id, "")
}

# aws_rds_cluster_instances
output "instances" {
  value = aws_rds_cluster_instance.aurora_postgresql_cluster_instance
}

# Enhanced monitoring role
output "enhanced_monitoring_iam_role_name" {
  value = try(aws_iam_role.rds_enhanced_monitoring.name, "")
}

output "enhanced_monitoring_iam_role_arn" {
  value = try(aws_iam_role.rds_enhanced_monitoring.arn, "")
}

output "enhanced_monitoring_iam_role_unique_id" {
  value = try(aws_iam_role.rds_enhanced_monitoring.unique_id, "")
}

# aws_security_group
output "security_group_id" {
  value = local.rds_security_group_id
}