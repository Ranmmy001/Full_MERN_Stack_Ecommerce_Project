locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  cluster_name = var.cluster_name

  network = {
    vpc_cidr             = var.vpc_cidr
    availability_zones   = var.availability_zones
    public_subnet_cidrs  = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
  }

  eks_node_group = {
    instance_types = var.node_instance_types
    desired_size   = var.node_desired_size
    min_size       = var.node_min_size
    max_size       = var.node_max_size
  }

  postgres = {
    db_name           = var.db_name
    db_username       = var.db_username
    instance_class    = var.db_instance_class
    allocated_storage = var.db_allocated_storage
  }

  eks_cluster = {
    name               = var.cluster_name
    kubernetes_version = var.kubernetes_version
  }
}