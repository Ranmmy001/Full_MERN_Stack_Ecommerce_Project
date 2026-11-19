output "aws_region" {
  description = "AWS region configured for this environment"
  value       = var.aws_region
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "eks_cluster_name" {
  description = "Planned EKS cluster name"
  value       = local.cluster_name
}

output "network_configuration" {
  description = "Planned VPC and subnet configuration"
  value       = local.network
}

output "eks_node_group_configuration" {
  description = "Planned EKS worker node configuration"
  value       = local.eks_node_group
}

output "postgres_configuration" {
  description = "Planned PostgreSQL configuration"
  value       = local.postgres
}

output "eks_cluster_configuration" {
  description = "Planned EKS cluster configuration"
  value       = local.eks_cluster
}

# ==========================================
# ECR OUTPUTS :PURPOSE: Output the URLs of all application ECR repositories created in this environment, allowing for easy reference and use in deployment pipelines or other configurations.
# ==========================================

output "ecr_repository_urls" {

  description = "URLs of all application ECR repositories"

  value = {
    for name, repository in aws_ecr_repository.app :
    name => repository.repository_url
  }
}

output "backend_secret_arn" { ## purpose: Output the ARN of the Secrets Manager secret for the backend application, allowing applications or services to reference and retrieve the secret securely without hardcoding sensitive information.
  description = "ARN of backend application secrets"
  value       = aws_secretsmanager_secret.backend.arn ## purpose: This outputs the Amazon Resource Name (ARN) of the AWS Secrets Manager secret that securely stores sensitive information for the backend application, enabling applications to retrieve the secrets without hardcoding them in configuration files.
}

output "mongodb_secret_arn" { ## purpose: Output the ARN of the Secrets Manager secret for MongoDB credentials, allowing applications or services to reference and retrieve the secret securely without hardcoding sensitive information.
  description = "ARN of MongoDB credentials"
  value       = aws_secretsmanager_secret.mongodb.arn ## purpose: This outputs the Amazon Resource Name (ARN) of the AWS Secrets Manager secret that securely stores MongoDB credentials, enabling applications to retrieve the credentials without hardcoding them in configuration files.
}






# This will allow Terraform to display the repository URLs after the infrastructure is created.

# They will look similar to:
# 603935308262.dkr.ecr.us-east-1.amazonaws.com/mern-ecommerce/backend