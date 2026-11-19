variable "aws_region" {
  description = "AWS region for the EKS environment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the ecommerce project"
  type        = string
  default     = "mern-ecommerce"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "aws"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "mern-ecommerce-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "vpc_cidr" {
  description = "CIDR range for the AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones for the AWS network"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "db_name" {
  description = "Database name for the Audit Service PostgreSQL database"
  type        = string
  default     = "ecommerce_audit"
}

variable "db_username" {
  description = "Master username for the Audit Service PostgreSQL database"
  type        = string
  default     = "audit_admin"
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial RDS PostgreSQL storage in GB"
  type        = number
  default     = 20
}

variable "eks_public_access_cidrs" {
  description = "Public IP CIDR ranges allowed to access the EKS Kubernetes API"
  type        = list(string)
}