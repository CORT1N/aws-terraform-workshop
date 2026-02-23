terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.33.0"
        }
    }
    required_version = ">= v1.10.6"
}