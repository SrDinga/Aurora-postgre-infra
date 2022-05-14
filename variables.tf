variable "name" {
  description = "Name used across resources created"
  type        = string
  default     = ""
}

variable "environment" {
  type        = string
  description = "Name of deployment environment (e.g. dev, qa, prod, etc.)"
  default     = ""
}

variable "aws_aurora_postgresql_cluster_tags" {
  type        = any
  description = "Map containing tags AWS RDS Aurora cluster and other resources "
  default     = {}
}

variable "aws_rds_aurora_cluster_config" {
  type        = any
  description = "This is a Variables which has all the Key Value pairs for aurora postgreSQL"
  default     = {}
}


variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks IP address ranges that can connect to this DB."
  type        = list(string)
  default     = []
}

variable "instance_timeouts" {
  description = "A list of timeouts for each instance in the cluster"
  type        = map(string)
  default     = {}
}

variable "auto_minor_version_upgrade" {
  description = "Configure the auto minor version upgrade behavior. Default is true."
  type        = bool
  default     = true
}

variable "autoscaling_enabled" {
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
  type        = bool
  default     = true
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 0
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 0
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 0
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 0
}

variable "autoscaling_target_cpu" {
  description = "Target value for the metric which will initiate autoscaling"
  type        = number
  default     = null
}

variable "autoscaling_target_connections" {
  type        = number
  description = "The number of connections to the database that the cluster will have"
  default     = null

}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

# The variable for instances gives you the ability to create multiple instances.# 
variable "instances" {
  description = "Map of instance types to the number of instances of that type to create"
  type        = map(any)
  default     = {}
}

variable "backup_retention_period" {
  description = "How many days to keep backup snapshots around before cleaning them up"
  type        = number
  default     = 7
}

variable "instances_use_identifier_prefix" {
  description = "tidentifier prefix for the read replica instances"
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "The Certificate Authority (CA) certificate bundle to use on the Aurora DB instances."
  type        = string
  default     = ""
}

variable "copy_tags_to_snapshot" {
  description = "Copy all the Aurora cluster tags to snapshots. Default is false."
  type        = bool
  default     = true
}

variable "create_db_subnet_group" {
  description = "Determines whether to create the database subnet group or use existing"
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "If true, a new DB subnet group will be created. If false, the existing DB subnet group will be used."
  type        = string
  default     = "db_subnet_group_postgres"
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster"
  default     = ""
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group to associate with instances"
  type        = string
  default     = ""
}

variable "enabled_cloudwatch_logs_exports" {
  description = "If non-empty, the Aurora cluster will export the specified logs to Cloudwatch. Must be zero or more of: audit, error, general and slowquery"
  type        = list(string)
  default     = []
}

variable "endpoints" {
  description = "Map of additional cluster endpoints and their attributes to be created"
  type        = any
  default     = {}
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Valid Value:aurora-postgresql"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_mode" {
  description = "The DB engine mode of the DB cluster: either provisioned, serverless, parallelquery, multimaster or global which only applies for global database clusters created with Aurora MySQL version 5.6.10a. For higher Aurora MySQL versions, the clusters in a global database use provisioned engine mode.. Limitations and requirements apply to some DB engine modes. See AWS documentation: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraSettingUp.html"
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "The Amazon Aurora DB engine version for the selected engine and engine_mode"
  type        = string
  default     = ""
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Disabled by default."
  type        = bool
  default     = true
}

variable "instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
  default     = ""
}

variable "instance_writer_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
  default     = null
}

variable "writer_identifier" {
  description = "determines the writer_instance"
  default     = "writer_instance"
  type        = string

}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = ""
}

variable "iam_role_description" {
  description = "Description of the monitoring role"
  type        = string
  default     = ""
}

variable "iam_role_managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the monitoring role"
  type        = list(string)
  default     = []
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the monitoring role"
  type        = number
  default     = null
}

variable "iam_role_path" {
  description = "Path for the monitoring role"
  type        = string
  default     = "/"
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the monitoring role"
  type        = string
  default     = ""
}

variable "master_username" {
  description = "The username for the master user. Required unless this is a secondary database in a global Aurora cluster."
  type        = string
  default     = ""
}

variable "master_password" {
  description = "The password for the master user. Required unless this is a secondary database in a global Aurora cluster. "
  type        = string
  default     = null
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  type        = string
  default     = ""
}

variable "create_monitoring_role" {
  description = "If true, a new IAM role will be created for the cluster. If false, the existing role will be used."
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance."
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not. On Aurora progresql"
  type        = bool
  default     = true
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = ""
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = 7
}

variable "port" {
  description = "The port the DB will listen on (e.g. 5432)"
  type        = number
  default     = 5432
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created (e.g. 04:00-09:00). Time zone is UTC."
  type        = string
  default     = ""
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = ""
}

variable "publicly_accessible" {
  description = "If you wish to make your database accessible from the public Internet, set this flag to true (WARNING: NOT RECOMMENDED FOR PRODUCTION USAGE!!). The default is false."
  type        = bool
  default     = false
}

variable "security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description"
  type        = string
  default     = null
}

variable "security_group_egress_rules" {
  description = "A map of security group egress rule defintions to add to the security group created"
  type        = map(any)
  default     = {}
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster uses encryption for data at rest in the underlying storage for the DB, its automated backups, Read Replicas, and snapshots. Uses the default aws/rds key in KMS."
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "A list of subnet ids where the database instances should be deployed. In the standard Gruntwork VPC setup, these should be the private persistence subnet ids. This is ignored if create_subnet_group=false."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "If true, a new security group will be created. If false, the existing security group will be used."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "The name of the security group. If value is set to empty string it will contain cluster name in the name"
  type        = string
  default     = ""
}

variable "allowed_security_groups" {
  description = "A list of security group ids that are allowed to connect to the database. If value is set to empty string it will contain cluster name in the name"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The id of the VPC in which this DB should be deployed."
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "The security group ids to apply to the DB cluster"
  type        = list(string)
  default     = []
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = true
}

variable "cluster_endpoint_identifier" {
  type        = string
  description = "The identifier of the cluster endpoint"
  default     = "static"
}

variable "iam_role_name" {
  type        = string
  description = "The name of the IAM role to use for the DB cluster"
  default     = "rolename"
}

variable "aws_iam_roles" {
  description = "Map of IAM roles and supported feature names to associate with the cluster"
  type        = map(map(string))
  default     = {}
}

variable "create_cluster" {
  description = "create aurora cluster"
  type        = bool
  default     = true
}

variable "rds_parameter_group" {
  description = "parameter group family name"
  type        = string
  default     = ""

}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`name`) is used as a prefix"
  type        = bool
  default     = true
}