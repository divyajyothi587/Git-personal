output "eks_cluster_endpoint" {
    description = "Endpoint for EKS control plane"
    value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
    description = "Certificate authority for EKS"
    value = aws_eks_cluster.aws_eks.certificate_authority 
}

output "eks_workernodes_subnet" {
    description = "subnet for ESK Worker nodes"
    value = var.eks_subnet_list
}

output "cluster_name" {
    description = "Kubernetes Cluster Name"
    value = aws_eks_cluster.aws_eks.name
}

output "s3_bucket_name" {
    description = "Frontend Bucket Name"
    value = aws_s3_bucket.frontend_bucket_name.bucket
}