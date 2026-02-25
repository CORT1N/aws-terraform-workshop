variable "infra_name" {
  description = "The name of the infrastructure"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy the infrastructure in"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnets" {
  description = "A map of subnet configurations"
  type = object({
    private = list(string)
    public  = list(string)
  })
}

variable "ssh_keys" {
  description = "A map of SSH key names to their public keys"
  type        = map(string)
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to deploy"
  type        = string
}