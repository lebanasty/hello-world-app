variable "region" {
  description = "AWS region we're deploying into"
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the k8s cluster"
  default = "hw_cluster"
}
