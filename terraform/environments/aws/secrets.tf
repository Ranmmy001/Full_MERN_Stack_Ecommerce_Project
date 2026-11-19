# Backend application secrets : purpose: Create a Secrets Manager secret to store sensitive information for the backend application, such as API keys, database credentials, or other secrets required for the application's operation. This ensures that sensitive data is securely stored and managed, reducing the risk of exposure in code or configuration files.
resource "aws_secretsmanager_secret" "backend" {
  name        = "${var.project_name}/${var.environment}/backend"
  description = "Backend application secrets for MERN ecommerce"

  recovery_window_in_days = 7 ## purpose: This sets the recovery window for the secret to 7 days, allowing for recovery of the secret within this time frame if it is deleted.

  tags = merge(local.common_tags, {
    Name      = "${var.project_name}-backend-secrets"
    Component = "backend"
  })
}

# MongoDB credentials
resource "aws_secretsmanager_secret" "mongodb" {
  name        = "${var.project_name}/${var.environment}/mongodb"
  description = "MongoDB credentials for MERN ecommerce"

  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name      = "${var.project_name}-mongodb-secrets"
    Component = "mongodb"
  })
}





# What does this create?
# Backend secret:

# Eventually holds:
# - JWT_SECRET
# - CLOUD_NAME
# - API_KEY
# - SECRET_KEY


# MongoDB secret:

# Eventually holds:
# - MongoDB username.
# - MongoDB password.
# - Other MongoDB connection details if required.
# Notice that am creating the secret containers, not putting actual passwords into Terraform.

# This prevents  unnecessarily storing application credentials in Terraform configuration and state.
