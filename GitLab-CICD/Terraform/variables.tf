variable "frontend_bucket_name" {
  description = "Name for the Frontend S3 bucket"
  type  = string
  default = "public-web-content-s3"
}

variable "eks_cluster_role" {
  description = "Name for the eks cluster role"
  type  = string
  default = "eks-cluster-role"
}

variable "eks_nodes_role" {
  description = "Name for the eks nodes role"
  type  = string
  default = "eks-nodes-role"
}

variable "eks_cluster_name" {
  description = "Name for the K8s cluster"
  type  = string
  default = "eks-cluster"
}

variable "eks_nodegroup_name" {
  description = "Name for the K8s worker nodes"
  type  = string
  default = "eks-nodes-group"
}

variable "eks_subnet_list" {
  description = "List of subnets for k8s cluster and worker node"
  type  = list
  default = ["subnet-06cd46e53ca6df9f3", "subnet-000df18f241b9dfdc", "subnet-0565dea0b064d2823"]
}

variable "eks_instance_type" {
  description = "Instance type of k8s worker node"
  type  = list
  default = ["t3.small"]
}

variable "capacity_type" {
  description = "IWorker node instance option (ON_DEMAND or SPOT)"
  type  = string
  default = "ON_DEMAND" # ON_DEMAND or SPOT
}

variable "disk_size" {
  description = "disk space for k8s worker node"
  type  = string
  default = "30"
}