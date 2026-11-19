# ==========================================
# 1. CREATE EKS CLUSTER : PURPOSE: Create an Amazon EKS cluster with the specified name, IAM role, Kubernetes version, and VPC configuration. The cluster will be associated with private subnets and have both private and public endpoint access enabled.
# ==========================================

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = aws_subnet.private[*].id ## purpose: This specifies the private subnets where the EKS cluster will be deployed, ensuring that the cluster's control plane and worker nodes are isolated from public internet access.

    endpoint_private_access = true ## Enable private access to the EKS cluster endpoint for resources within the VPC.
    endpoint_public_access  = true ## Enable public access to the EKS cluster endpoint for resources outside the VPC.

    public_access_cidrs = var.eks_public_access_cidrs ## Specify the CIDR ranges allowed to access the EKS Kubernetes API from public networks.

  }



  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}


# ==========================================
# 2. CREATE EKS MANAGED NODE GROUP : PURPOSE: Create an Amazon EKS managed node group with the specified name, IAM role, instance types, and scaling configuration. The node group will be associated with private subnets and will depend on the necessary IAM role policy attachments for worker nodes, CNI, and ECR access.
# ==========================================

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.eks_node.arn

  subnet_ids = aws_subnet.private[*].id

  instance_types = var.node_instance_types

  scaling_config { ## purpose: This block defines the scaling configuration for the EKS managed node group, including the desired, minimum, and maximum number of nodes in the group.
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  tags = local.common_tags

  depends_on = [ ## purpose: This block specifies the dependencies for the EKS managed node group, ensuring that the necessary IAM role policy attachments for worker nodes, CNI, and ECR access are created before the node group is provisioned.
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr
  ]
}





# The worker nodes will be deployed into our private subnets.

# The EKS control plane is managed by AWS, while the worker nodes provide the computing resources for our application containers.

# One security note: i enabled both public and private Kubernetes API access for initial administration. Before deployment, i should restrict public access to the trusted IP address.