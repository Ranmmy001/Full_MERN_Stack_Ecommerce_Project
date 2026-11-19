# ==========================================
# 1. EKS CLUSTER IAM ROLE : for the EKS cluster, create an IAM role that allows the EKS service to manage AWS resources on behalf of the cluster.
# ==========================================

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = { ## This policy allows the EKS service to assume this role, enabling it to manage AWS resources on behalf of the cluster.
        Service = "eks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}


# ==========================================
# 2. ATTACH EKS CLUSTER POLICY : for the EKS cluster IAM role, attach the AmazonEKSClusterPolicy managed policy to grant necessary permissions for EKS operations.
# ==========================================

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# ==========================================
# 3. EKS WORKER NODE IAM ROLE : for the EKS worker nodes, create an IAM role that allows the EC2 instances to interact with the EKS cluster and other AWS services.
# ==========================================

resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({ ## This policy allows EC2 instances to assume this role, enabling them to interact with the EKS cluster and other AWS services.
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}


# ==========================================
# 4. WORKER NODE POLICY ATTACHMENT : for the EKS worker node IAM role, attach the AmazonEKSWorkerNodePolicy managed policy to grant necessary permissions for worker node operations.
# ==========================================

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role = aws_iam_role.eks_node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# ==========================================
# 5. AMAZON VPC CNI POLICY : for the EKS worker node IAM role, attach the AmazonEKS_CNI_Policy managed policy to grant necessary permissions for networking operations.
# ==========================================

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role = aws_iam_role.eks_node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# ==========================================
# 6. AMAZON ECR READ ONLY POLICY : for the EKS worker node IAM role, attach the AmazonEC2ContainerRegistryReadOnly managed policy to grant read-only access to Amazon ECR repositories.
# ==========================================

resource "aws_iam_role_policy_attachment" "eks_ecr" {
  role = aws_iam_role.eks_node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# ### What does this file accomplish?
# i created two separate IAM roles.

# ONE - EKS Cluster Role

# Allows the EKS control plane to manage the AWS resources it needs.

# TWO - EKS Worker Node Role

# Allows our EC2 worker nodes to:
# - Connect to the EKS cluster.
# - Configure Kubernetes networking.
# - Pull container images from Amazon ECR.