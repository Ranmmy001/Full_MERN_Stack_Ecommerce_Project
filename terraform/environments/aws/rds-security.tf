# ==========================================
# RDS SECURITY GROUP : purpose: Create a security group for the PostgreSQL RDS instance, allowing inbound connections on port 5432 from within the VPC and allowing all outbound traffic. This security group will be associated with the RDS instance to control network access.
# ==========================================

resource "aws_security_group" "rds" {

  name        = "${var.project_name}-rds-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.main.id

  # Allow PostgreSQL connections from within the VPC.
  # will restrict this further when the audit service
  # and its EKS networking are configured.

  ingress { ## This block defines an inbound rule for the security group, allowing TCP traffic on port 5432 (the default port for PostgreSQL) from the specified CIDR block of the VPC. This enables access to the PostgreSQL RDS instance from resources within the VPC.
    description = "PostgreSQL access from the VPC"

    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp" ## This specifies that the rule applies to TCP traffic, which is the protocol used by PostgreSQL for database connections.
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow outbound traffic.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-rds-sg"
  })
}



# PostgreSQL listens on port 5432.

# This rule allows resources with network access inside your VPC to connect to the database. It does not expose PostgreSQL to the public internet.