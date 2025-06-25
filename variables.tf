variable "application_name" {
  description = "Name of the application that is using this elasticache"
  type        = string
}

variable "security_group_ids" {
  description = "Security Groups that are allowed to access the cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC the ElastiCache cluster will be in"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets where the elasticache will be placed"
  type        = list(string)
}

variable "node_type" {
  description = "Instance type for the nodes"
  type        = string

  default = "cache.t2.small"
}

variable "availability_zones" {
  description = "Availability zones to run in"
  type        = list(string)

  default = []
}

variable "engine_version" {
  description = "The version of redis to use"
  type        = string

  default = "5.0.5"
}

variable "parameter_group_name" {
  description = "Parameter group to use for the engine"
  type        = string

  default = "default.redis5.0"
}

variable "user_group_ids" {
  description = "User Group ID to associate with the replication group (Optional)"
  type        = list(string)

  default = null
}
