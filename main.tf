terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}



locals {
  create_security_group       = lookup(var.aws_rds_aurora_cluster_config, "create_security_group", var.create_security_group)
  security_group_egress_rules = lookup(var.aws_rds_aurora_cluster_config, "security_group_egress_rules", var.security_group_egress_rules)
  arn                         = [aws_iam_role.rds_enhanced_monitoring.name]
  create_cluster              = lookup(var.aws_rds_aurora_cluster_config, "create_cluster", var.create_cluster)
  engine_version              = lookup(var.aws_rds_aurora_cluster_config, "engine_version", var.engine_version)
  rds_security_group_id       = aws_security_group.aurora_postgresql_security_group.id
  rds_enhanced_monitoring_arn = var.create_monitoring_role ? join("", [aws_iam_role.rds_enhanced_monitoring.arn]) : var.monitoring_role_arn
  cluster_name                = format("aws-aurorapgsl-%s-%s", var.environment, lookup(var.aws_rds_aurora_cluster_config, "name", var.name))
  instances = {
    1 = {
      instance_class      = lookup(var.aws_rds_aurora_cluster_config, "instance_class", var.instance_class)
      publicly_accessible = false
    }
    2 = {
      identifier     = lookup(var.aws_rds_aurora_cluster_config, "writer_identifier", var.writer_identifier)
      instance_class = lookup(var.aws_rds_aurora_cluster_config, "instance_writer_class", var.instance_writer_class)
      promotion_tier = 15
    }
  }
  autoscaling_properties = [
    {
      max_capacity = lookup(var.aws_rds_aurora_cluster_config, "autoscaling_max_capacity", var.autoscaling_max_capacity)
      min_capacity = lookup(var.aws_rds_aurora_cluster_config, "autoscaling_min_capacity", var.autoscaling_min_capacity)
      resource_id  = "cluster:${try(aws_rds_cluster.aurora_postgresql_cluster.cluster_identifier, "")}"
    }
  ]
}

################################################################################
# Creating Aurora postgresql cluster Subnet Group
################################################################################

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = lookup(var.aws_rds_aurora_cluster_config, "db_subnet_group_name", var.db_subnet_group_name)
  description = "Subnet group for the ${local.name  } DB"
  subnet_ids  = lookup(var.aws_rds_aurora_cluster_config, "subnet_ids", var.subnet_ids)

  tags = var.aws_aurora_postgresql_cluster_tags
}

################################################################################
# Creating Aurora postgresql cluster 
################################################################################

resource "aws_rds_cluster" "aurora_postgresql_cluster" {

  cluster_identifier                  = local.cluster_name
  engine                              = lookup(var.aws_rds_aurora_cluster_config, "engine", var.engine)
  engine_mode                         = lookup(var.aws_rds_aurora_cluster_config, "engine_mode", var.engine_mode)
  engine_version                      = lookup(var.aws_rds_aurora_cluster_config, "engine_version", var.engine_version)
  kms_key_id                          = lookup(var.aws_rds_aurora_cluster_config, "kms_key_id", var.kms_key_id == "" ? null : var.kms_key_id)
  database_name                       = lookup(var.aws_rds_aurora_cluster_config, "database_name", var.database_name)
  master_username                     = lookup(var.aws_rds_aurora_cluster_config, "master_username", var.master_username)
  master_password                     = lookup(var.aws_rds_aurora_cluster_config, "master_password", var.master_password)
  skip_final_snapshot                 = lookup(var.aws_rds_aurora_cluster_config, "skip_final_snapshot", var.skip_final_snapshot)
  backup_retention_period             = lookup(var.aws_rds_aurora_cluster_config, "backup_retention_period", var.backup_retention_period)
  preferred_backup_window             = lookup(var.aws_rds_aurora_cluster_config, "preferred_backup_window", var.preferred_backup_window)
  preferred_maintenance_window        = lookup(var.aws_rds_aurora_cluster_config, "preferred_maintenance_window", var.preferred_maintenance_window)
  port                                = lookup(var.aws_rds_aurora_cluster_config, "port", var.port)
  db_subnet_group_name                = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids              = [aws_security_group.aurora_postgresql_security_group.id]
  storage_encrypted                   = lookup(var.aws_rds_aurora_cluster_config, "storage_encrypted", var.storage_encrypted)
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.cluster_parameter.id
  iam_database_authentication_enabled = lookup(var.aws_rds_aurora_cluster_config, "iam_database_authentication_enabled", var.iam_database_authentication_enabled)
  copy_tags_to_snapshot               = lookup(var.aws_rds_aurora_cluster_config, "copy_tags_to_snapshot", var.copy_tags_to_snapshot)
  enabled_cloudwatch_logs_exports     = lookup(var.aws_rds_aurora_cluster_config, "enabled_cloudwatch_logs_exports", var.enabled_cloudwatch_logs_exports)

  tags = var.aws_aurora_postgresql_cluster_tags
  lifecycle {
    ignore_changes = [
      cluster_identifier
    ]
  }
}



################################################################################
# Creating Aurora postgresql cluster instance
################################################################################
resource "aws_rds_cluster_instance" "aurora_postgresql_cluster_instance" {
  for_each = local.create_cluster ? local.instances : {}

  cluster_identifier                    = try(aws_rds_cluster.aurora_postgresql_cluster.id, "")
  engine                                = lookup(var.aws_rds_aurora_cluster_config, "engine", var.engine)
  engine_version                        = local.engine_version
  instance_class                        = lookup(each.value, "instance_class", var.instance_class)
  publicly_accessible                   = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  db_subnet_group_name                  = aws_db_subnet_group.aurora_subnet_group.name
  db_parameter_group_name               = aws_db_parameter_group.cluster_instance_parameter.id
  monitoring_role_arn                   = local.rds_enhanced_monitoring_arn
  monitoring_interval                   = lookup(each.value, "monitoring_interval", var.monitoring_interval)
  availability_zone                     = lookup(each.value, "availability_zone", null)
  preferred_maintenance_window          = lookup(each.value, "preferred_maintenance_window", var.preferred_maintenance_window)
  auto_minor_version_upgrade            = lookup(each.value, "auto_minor_version_upgrade", var.auto_minor_version_upgrade)
  performance_insights_enabled          = lookup(each.value, "performance_insights_enabled", var.performance_insights_enabled)
  performance_insights_kms_key_id       = lookup(each.value, "performance_insights_kms_key_id", var.performance_insights_kms_key_id)
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", var.performance_insights_retention_period)
  copy_tags_to_snapshot                 = lookup(each.value, "copy_tags_to_snapshot", var.copy_tags_to_snapshot)
  ca_cert_identifier                    = lookup(each.value, "ca_cert_identifier", var.ca_cert_identifier)

  timeouts {
    create = lookup(var.instance_timeouts, "create", null)
    update = lookup(var.instance_timeouts, "update", null)
    delete = lookup(var.instance_timeouts, "delete", null)
  }
  tags = var.aws_aurora_postgresql_cluster_tags
  lifecycle {
    ignore_changes = [
      cluster_identifier
    ]
  }
}

# Note: when consuming this module the "rds_parameter_group" variables are passed based on the version engiine
resource "aws_db_parameter_group" "cluster_instance_parameter" {
  name = "${var.name}-db-parameter-group"
  family      = lookup(var.aws_rds_aurora_cluster_config, "rds_parameter_group", var.rds_parameter_group)
  description = "${var.name}-db-parameter-group"

  /* tags = var.aws_aurora_postgresql_cluster_tags */
}

resource "aws_rds_cluster_parameter_group" "cluster_parameter" {
  name = "${var.name}-cluster-parameter-group"
  family      = lookup(var.aws_rds_aurora_cluster_config, "rds_parameter_group", var.rds_parameter_group)
  description = "${var.name}-cluster-parameter-group"

  /* tags = var.aws_aurora_postgresql_cluster_tags */
}

resource "aws_rds_cluster_endpoint" "aurora_postgresql_cluster_endpoint" {
  for_each                    = lookup(var.aws_rds_aurora_cluster_config, "endpoints", var.endpoints)
  cluster_identifier          = try(aws_rds_cluster.aurora_postgresql_cluster.id, "")
  cluster_endpoint_identifier = each.value.identifier
  custom_endpoint_type        = each.value.type

  static_members   = lookup(each.value, "static_members", null)
  excluded_members = lookup(each.value, "excluded_members", null)

  depends_on = [
    aws_rds_cluster_instance.aurora_postgresql_cluster_instance
  ]

  tags = var.aws_aurora_postgresql_cluster_tags
}

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

################################################################################
# Enhanced Monitoring
################################################################################

resource "aws_iam_role" "rds_enhanced_monitoring" {

  name                 = lookup(var.aws_rds_aurora_cluster_config, "iam_role_name", var.iam_role_name)
  description          = lookup(var.aws_rds_aurora_cluster_config, "iam_role_description", var.iam_role_description)
  path                 = lookup(var.aws_rds_aurora_cluster_config, "iam_role_path", var.iam_role_path)
  assume_role_policy   = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns  = lookup(var.aws_rds_aurora_cluster_config, "iam_role_managed_policy_arns", var.iam_role_managed_policy_arns)
  permissions_boundary = lookup(var.aws_rds_aurora_cluster_config, "iam_role_permissions_boundary", var.iam_role_permissions_boundary)

  tags = var.aws_aurora_postgresql_cluster_tags

}

data "aws_partition" "current" {}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role = aws_iam_role.rds_enhanced_monitoring.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

################################################################################
# Autoscaling
################################################################################

resource "aws_appautoscaling_target" "aurora_postgresql_cluster_scaling_target" {
  for_each = {
    for idx, autoscaling_properties in local.autoscaling_properties : idx => autoscaling_properties
    if(var.autoscaling_enabled)
  }

  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = each.value.resource_id
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "aurora_postgresql_cluster_scaling_policy" {

  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${try(aws_rds_cluster.aurora_postgresql_cluster.cluster_identifier, "")}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = lookup(var.aws_rds_aurora_cluster_config, "predefined_metric_type", var.predefined_metric_type)
    }

    scale_in_cooldown  = lookup(var.aws_rds_aurora_cluster_config, "autoscaling_scale_in_cooldown", var.autoscaling_scale_in_cooldown)
    scale_out_cooldown = lookup(var.aws_rds_aurora_cluster_config, "autoscaling_scale_out_cooldown", var.autoscaling_scale_out_cooldown)
    target_value       = lookup(var.aws_rds_aurora_cluster_config, "autoscaling_target_cpu", var.autoscaling_target_cpu)
  }

  depends_on = [
    aws_appautoscaling_target.aurora_postgresql_cluster_scaling_target
  ]
}


################################################################################
# Security Group
################################################################################


resource "aws_security_group" "aurora_postgresql_security_group" {
  # name        = "${local.name}-security-group"
  name        = var.security_group_use_name_prefix ? null : local.name 
  name_prefix = var.security_group_use_name_prefix ? "${local.name }-" : null
  vpc_id      = lookup(var.aws_rds_aurora_cluster_config, "vpc_id", var.vpc_id)
  description = lookup(var.aws_rds_aurora_cluster_config, "security_group_description", var.security_group_description)
  tags        = var.aws_aurora_postgresql_cluster_tags
}

resource "aws_security_group_rule" "allowed_connections_from_security_groups" {

  for_each          = toset(lookup(var.aws_rds_aurora_cluster_config, "allowed_security_groups", var.allowed_security_groups))
  type              = "ingress"
  from_port         = lookup(var.aws_rds_aurora_cluster_config, "port", var.port)
  to_port           = lookup(var.aws_rds_aurora_cluster_config, "port", var.port)
  protocol          = "tcp"
  security_group_id = local.rds_security_group_id

  description              = lookup(var.aws_rds_aurora_cluster_config, "security_group_description", var.security_group_description)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

resource "aws_security_group_rule" "cidr_ingress" {

  for_each    = toset(var.allowed_cidr_blocks)
  description = "From allowed CIDRs"
  type        = "ingress"
  from_port   = lookup(var.aws_rds_aurora_cluster_config, "port", var.port)
  to_port     = lookup(var.aws_rds_aurora_cluster_config, "port", var.port)
  protocol    = "tcp"
  cidr_blocks = lookup(var.aws_rds_aurora_cluster_config, "allowed_cidr_blocks", var.allowed_cidr_blocks)

  security_group_id = local.rds_security_group_id

}

resource "aws_security_group_rule" "egress" {

  for_each          = local.create_cluster && local.create_security_group ? local.security_group_egress_rules : {}
  type              = "egress"
  from_port         = lookup(var.aws_rds_aurora_cluster_config, "port", var.port)
  to_port           = lookup(var.aws_rds_aurora_cluster_config, "port", var.port)
  protocol          = "tcp"
  security_group_id = each.key


  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}
