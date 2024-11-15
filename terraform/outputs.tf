output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS Kubernetes API"
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "The ID of the VPC"
  value = module.vpc.vpc_id
}

output "eks_node_group_role_arn" {
  description = "ARN of the IAM role associated with the EKS node group"
  value       = module.eks.eks_managed_node_groups["eks_nodes"].iam_role_arn
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

resource "local_file" "kubeconfig" {
  content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name = data.aws_eks_cluster.eks.name
    endpoint = data.aws_eks_cluster.eks.endpoint
    ca_data = data.aws_eks_cluster.eks.certificate_authority[0].data
    token = data.aws_eks_cluster_auth.eks.token
  })
  filename = "${path.module}/kubeconfig"
}

output "kubeconfig_file" {
  value = local_file.kubeconfig.filename
  description = "Path to the kubeconfig file for the EKS cluster"
}
