# ==========================================
# ECR REPOSITORIES :purpose: Create Amazon ECR repositories for different components of the application, such as backend, frontend, admin, and audit-service. Each repository will have image scanning enabled and use AES256 encryption.
# ==========================================

locals {
  ecr_repositories = toset([ ## This local variable defines a set of ECR repository names for different components of the application, which will be used to create the corresponding ECR repositories.
    "backend",
    "frontend",
    "admin",
    "audit-service"
  ])
}

# ==========================================
# CREATE ECR REPOSITORIES :purpose: Create Amazon ECR repositories for different components of the application, such as backend, frontend, admin, and audit-service. Each repository will have image scanning enabled and use AES256 encryption.
# ==========================================

resource "aws_ecr_repository" "app" {

  for_each = local.ecr_repositories ## This block iterates over the set of ECR repository names defined in the local variable `ecr_repositories`, creating an ECR repository for each component of the application.

  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = "MUTABLE" ## This block specifies that the image tags in the ECR repository can be updated or overwritten, allowing for flexibility in managing container image versions.

  image_scanning_configuration { ## This block enables image scanning on push for the ECR repository, allowing for automatic vulnerability scanning of container images when they are pushed to the repository.
    scan_on_push = true
  }

  encryption_configuration { ## This block specifies the encryption settings for the ECR repository, using AES256 encryption to secure the stored container images.
    encryption_type = "AES256"
  }

  tags = {
    Name      = "${var.project_name}-${each.value}"
    Component = each.value
  }
}

# ==========================================
# ECR LIFECYCLE POLICY : purpose: Define lifecycle policies for the ECR repositories to manage image retention. The policies will delete untagged images older than 7 days and keep only the latest 10 tagged images, helping to optimize storage usage and maintain a clean repository.
# ==========================================

resource "aws_ecr_lifecycle_policy" "app" {

  for_each = aws_ecr_repository.app

  repository = each.value.name

  policy = jsonencode({ ## This block defines the lifecycle policy for the ECR repository, specifying rules for image retention and expiration.

    rules = [

      {
        rulePriority = 1

        description = "Delete untagged images older than 7 days" ## This rule specifies that untagged images in the ECR repository that are older than 7 days will be automatically deleted, helping to free up storage space and maintain a clean repository.

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }

        action = {
          type = "expire"
        }
      },

      {
        rulePriority = 2 ## This rule specifies that only the latest 10 tagged images in the ECR repository will be retained, and any older tagged images beyond this limit will be automatically deleted, helping to manage storage usage and maintain a clean repository.

        description = "Keep only the latest 10 tagged images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }

    ]

  })
}



#     Step 3: UNDERSTANDING WHAT THIS CONFIGURATION DOES::::
# There are four important things happening.

# A. Creates four repositories
# locals {
#   ecr_repositories = toset([
#     "backend",
#     "frontend",
#     "admin",
#     "audit-service"
#   ])
# }

# Instead of writing four separate ECR resources, we use for_each to create them from one configuration.

# B. Makes AWS scan uploaded images
# image_scanning_configuration {
#   scan_on_push = true
# }

# Whenever an image is pushed, ECR scans it for known vulnerabilities.

# C. Encrypts images
# encryption_configuration {
#   encryption_type = "AES256"
# }

# This enables encryption at rest for the images stored in ECR.

# D. Controls storage growth

# The lifecycle policy:
# - Deletes untagged images older than seven days.
# - Keeps the latest ten tagged images.
# This helps prevent unnecessary accumulation of old images.