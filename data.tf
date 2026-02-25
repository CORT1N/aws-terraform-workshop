data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "main" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami*-kernel-6.12-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# data "tls_certificate" "cluster" {
#   url = aws_eks_cluster.main.identity[0].oidc[0].issuer
# }
