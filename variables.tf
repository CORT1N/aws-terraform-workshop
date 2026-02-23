locals {
  subnets = {
    "priv-01" = { cidr = "10.0.10.0/24", az = "eu-west-3a", public = false }
    "priv-02" = { cidr = "10.0.20.0/24", az = "eu-west-3b", public = false }
    "priv-03" = { cidr = "10.0.30.0/24", az = "eu-west-3c", public = false }
    "pub-01"  = { cidr = "10.0.40.0/24", az = "eu-west-3a", public = true }
    "pub-02"  = { cidr = "10.0.50.0/24", az = "eu-west-3b", public = true }
    "pub-03"  = { cidr = "10.0.60.0/24", az = "eu-west-3c", public = true }
  }
}