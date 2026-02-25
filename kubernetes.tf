resource "aws_kms_key" "eks" {
  description = "EKS cluster encryption key"
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.infra_name}/cluster"
  retention_in_days = 7
}

resource "aws_eks_cluster" "main" {
  name     = var.infra_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs    = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_cloudwatch_log_group.cluster
  ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.infra_name}-main"
  node_role_arn   = aws_iam_role.node_group.arn
    subnet_ids = aws_subnet.private[*].id
  scaling_config {
    desired_size = 6
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable_percentage = 33
  }

  instance_types = ["t3.micro"]

  disk_size = 20

  labels = {
    role = "general"
  }

  tags = {
    "k8s.io/cluster-autoscaler/${var.infra_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policies
  ]
}

resource "null_resource" "kubectl_config" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${var.infra_name}"
  }
  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
}