# ==========================================
# RDS SUBNET GROUP :purpose: Create a subnet group for the PostgreSQL RDS instance, associating it with the private subnets in the VPC. This subnet group will be used by the RDS instance to determine which subnets it can be deployed into, ensuring that the database is placed in private subnets for security.
# ==========================================

resource "aws_db_subnet_group" "main" {

  name = "${var.project_name}-rds-subnet-group"

  subnet_ids = aws_subnet.private[*].id

  description = "Private subnets for PostgreSQL RDS"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-rds-subnet-group"
  })
}


# ==========================================
# POSTGRESQL RDS INSTANCE : purpose: Create a PostgreSQL RDS instance with the specified configuration, including engine version, instance class, storage, network settings, and backup/maintenance options. The instance will be associated with the previously created subnet group and security group, and AWS Secrets Manager will manage the master password for enhanced security.
# ==========================================

resource "aws_db_instance" "postgres" {

  identifier = "${var.project_name}-audit-db" ## purpose: This sets the unique identifier for the RDS instance, which will be used to reference the database in AWS. It combines the project name with a descriptive suffix to indicate that this is the audit database.

  # Database engine

  engine         = "postgres"
  engine_version = "16"

  instance_class = var.db_instance_class

  # Database configuration

  db_name  = var.db_name
  username = var.db_username

  port = 5432

  # Storage configuration

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true ## purpose: This enables encryption for the RDS instance's storage, ensuring that the data at rest is protected using AWS-managed encryption keys.

  # AWS manages the master password through Secrets Manager.

  manage_master_user_password = true ## purpose: This enables AWS Secrets Manager to manage the master user password for the RDS instance, providing enhanced security by automatically rotating the password and storing it securely.

  # Network configuration

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false ## purpose: This ensures that the RDS instance is not accessible from the public internet, enhancing security by restricting access to resources within the VPC.

  # Backup configuration

  backup_retention_period = 7 ## purpose: This sets the number of days to retain automated backups of the RDS instance, allowing for point-in-time recovery within this retention period.
  backup_window           = "03:00-04:00"

  # Maintenance configuration

  maintenance_window         = "sun:04:00-sun:05:00" ## purpose: This specifies the preferred time window for maintenance activities, such as software patching and updates, to minimize disruption to the database operations.
  auto_minor_version_upgrade = true                  ## purpose: This enables automatic minor version upgrades for the RDS instance, ensuring that the database engine is kept up-to-date with the latest security patches and improvements without manual intervention.

  # Cost and development configuration

  multi_az = false ## purpose: This disables Multi-AZ deployment for the RDS instance, which is suitable for development and testing environments where high availability is not a primary concern.

  # Lab environment settings.
  # Review these before production deployment.

  deletion_protection = false ## purpose: This disables deletion protection for the RDS instance, allowing it to be deleted if necessary. In production environments, it is recommended to enable deletion protection to prevent accidental deletion of the database.
  skip_final_snapshot = true  ## purpose: This skips the creation of a final snapshot when the RDS instance is deleted, which can be useful in development environments to avoid unnecessary storage costs. In production, it is recommended to create a final snapshot for data recovery purposes.

  tags = merge(local.common_tags, {
    Name      = "${var.project_name}-audit-db"
    Component = "audit-database"
  })

  depends_on = [ ## purpose: This specifies the dependencies for the RDS instance, ensuring that the subnet group and security group are created before the RDS instance is provisioned.
    aws_db_subnet_group.main,
    aws_security_group.rds
  ]
}



# explanation of the important sections

# A. RDS subnet group
# subnet_ids = aws_subnet.private[*].id

# This tells AWS to place the database in the private subnets we created in network.tf.

# B. PostgreSQL engine
# engine         = "postgres"
# engine_version = "16"

# We are selecting PostgreSQL 16.

# C. Database credentials
# manage_master_user_password = true

# This is important.

# Instead of writing the database password inside Terraform, AWS RDS generates and manages the master password using Secrets Manager.

# D. Public accessibility
# publicly_accessible = false

# This prevents the database from being publicly accessible.

# E. Backup
# backup_retention_period = 7

# AWS will retain automated backups for seven days.

# F. Cost control
# multi_az = false

# We are using a single-AZ database initially to avoid the additional cost of a Multi-AZ deployment.

# For production, it  would  be reconsidered. the setting.