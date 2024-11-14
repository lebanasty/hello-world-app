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
