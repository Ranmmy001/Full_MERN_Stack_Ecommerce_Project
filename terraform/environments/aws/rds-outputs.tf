# ==========================================
# RDS OUTPUTS : PURPOSE: Output the PostgreSQL RDS instance details, including endpoint, port, database name, and the ARN of the Secrets Manager secret containing the master password. These outputs facilitate easy access to the database connection information for application configuration and management.
# ==========================================

output "postgres_endpoint" {

  description = "PostgreSQL RDS endpoint"

  value = aws_db_instance.postgres.address ## purpose: This outputs the endpoint address of the PostgreSQL RDS instance, which is used to connect to the database from applications or other services.
}


output "postgres_port" {

  description = "PostgreSQL database port"

  value = aws_db_instance.postgres.port ## purpose: This outputs the port number on which the PostgreSQL RDS instance is listening, allowing applications to configure their database connection settings accordingly.
}


output "postgres_database_name" {

  description = "PostgreSQL database name"

  value = aws_db_instance.postgres.db_name ## purpose: This outputs the name of the PostgreSQL database created within the RDS instance, which is used by applications to specify the target database for their operations.
}


output "postgres_secret_arn" {

  description = "ARN of the Secrets Manager secret containing the RDS master password"

  value = aws_db_instance.postgres.master_user_secret[0].secret_arn ## purpose: This outputs the Amazon Resource Name (ARN) of the AWS Secrets Manager secret that securely stores the master password for the PostgreSQL RDS instance, enabling applications to retrieve the password without hardcoding it in configuration files.
}







# These outputs will be useful when connecting the audit service to PostgreSQL.

# For example, after Terraform creates the database, its endpoint might look like:
# mern-ecommerce-audit-db.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com