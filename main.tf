terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

/*
 * == ElastiCache
 *
 * Setup the service!
 */

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.application_name}-cache-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.application_name
  description          = "Replication group for ElastiCache"

  engine               = "redis"
  engine_version       = var.engine_version
  parameter_group_name = var.parameter_group_name

  node_type = var.node_type
  port      = 6379

  preferred_cache_cluster_azs = var.availability_zones
  multi_az_enabled            = length(var.availability_zones) != 0
  num_cache_clusters          = length(var.availability_zones) == 0 ? 1 : length(var.availability_zones)
  automatic_failover_enabled  = length(var.availability_zones) != 0

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]
  user_group_ids     = var.user_group_ids
}

/*
 * == Security Groups
 *
 * Allow the given services to communicate with Elasticache
 */
resource "aws_security_group" "this" {
  name = "${var.application_name}-redis-cluster"

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress_from_application_to_elasticache" {
  count = length(var.security_group_ids)

  security_group_id = aws_security_group.this.id

  type = "ingress"

  protocol                 = "tcp"
  from_port                = aws_elasticache_replication_group.this.port
  to_port                  = aws_elasticache_replication_group.this.port
  source_security_group_id = var.security_group_ids[count.index]
}

resource "aws_security_group_rule" "egress_from_application_to_elasticache" {
  count = length(var.security_group_ids)

  security_group_id = var.security_group_ids[count.index]

  type = "egress"

  protocol                 = "tcp"
  from_port                = aws_elasticache_replication_group.this.port
  to_port                  = aws_elasticache_replication_group.this.port
  source_security_group_id = aws_security_group.this.id
}
