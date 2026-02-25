infra_name = "esgi"
region = "eu-west-3"

vpc_cidr = "10.0.0.0/16"

subnets = {
    "private" = [
        "10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"
    ]
    "public" = [
        "10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"
    ]
}

ssh_keys = {
    "lucas" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDtxwEDlzrFutmvphUBVxv99ZS7I4Jps1ybNYX9RnWptYfNd+wWieUSzxMIOG+chJwuoBs6VFcmgn+RZrmsNb3peYXiVgU1stMAZFaPk+nhMh+AEzzsgonqfXR6EtcESTlwoXuzPOKmzBM7ardEx0ch41xtWKqf7V3LGX5W41hGhX4pIjPOuR4O0ZRKmwCVLzuxh4laDtKMwq8B2QpLHmX0YTRD2j7ZeEUgUG9nokuLKpd4AAAUTiJpxlgWtMlaGwsa29vRP3dyL2pmKGc4CNQxu2kOSPnUavuUaYcF1MWHXsXVWO1gJOOW9A645VZuC/3BedG9uT4Uv/Tnh+jBsP2woBre5KG+1D8QEjQje0ew1tlW9QR8Stx2Z9YJm4nOA0agZwc5lQLVr/mydb6jC+x1QwdoJgcyZB1+IlWGIWAzvgSogIeLu6K4Elstoqd4/GCxLoda0A3+ADO0aNhmW/2QH+PWQKsBcZv41jMCmSDm2QLKpzZ7YTG5E3c5ivWGnIhbUdTJ26I0UpI+j9I82iM6Iidd8kLXa77lM3l/jKmby8zwd9EQbbOn2CTv+RTpHSGfdW82x2DJ7wifTMBs85Yh9YA8rlZB0OdlWU4L/NwWOhF7Pw1JBbLy/Rae9tP27H/Swt1EaIqiREsXeABtRWDG1B+YYS/8XKhbcBAg643Gvw== cort1n@Optimus"
}

kubernetes_version = "1.35"