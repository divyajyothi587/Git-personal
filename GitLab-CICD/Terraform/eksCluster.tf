
# Cluster Role
resource "aws_iam_role" "eks_cluster_role" {
    name = var.eks_cluster_role
    assume_role_policy = file("template/eksClusterRolePolicy.json")
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks_cluster_role.name
}


# WorkerNode Role
resource "aws_iam_role" "eks_nodes_role" {
  name = var.eks_nodes_role
  assume_role_policy = file("template/eksNodesRolePolicy.json")
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_nodes_role.name
}


# EKS Cluster
resource "aws_eks_cluster" "aws_eks" {
  name = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.eks_subnet_list
  }

  tags = {
    Name = var.eks_cluster_name
    Environment = "Dev"
    Application = "K8s"
  }
}


# EKS WorkerNodes
resource "aws_eks_node_group" "worker_node" {
  cluster_name = aws_eks_cluster.aws_eks.name
  node_group_name = var.eks_nodegroup_name
  node_role_arn = aws_iam_role.eks_nodes_role.arn
  subnet_ids = var.eks_subnet_list
  instance_types = var.eks_instance_type
  capacity_type = var.capacity_type
  disk_size = var.disk_size


  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}