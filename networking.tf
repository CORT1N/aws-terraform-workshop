resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
      Name = var.infra_name
  }
}

resource "aws_subnet" "private" {
  count = length(var.subnets.private)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets.private[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "esgi-priv-${count.index + 1}"
    Type = "private"
  }
}

resource "aws_subnet" "public" {
  count = length(var.subnets.public)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets.public[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "esgi-public-${count.index + 1}"
    Type = "public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.infra_name
  }
}

resource "aws_eip" "main" {
  domain = "vpc"
  tags = {
    Name = var.infra_name
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = var.infra_name
  }
}

resource "aws_route_table" "main_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.infra_name}-private"
  }
}

resource "aws_route_table" "main_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.infra_name}-public"
  }
}

resource "aws_route_table_association" "private" {
    count = length(var.subnets.private)

    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.main_private.id
}

resource "aws_route_table_association" "public" {
    count = length(var.subnets.public)

    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.main_public.id
}

resource "aws_security_group" "main" {
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.infra_name
  }
}

resource "aws_network_interface" "bastion_internal" {
  subnet_id   = aws_subnet.private[0].id
  security_groups = [aws_security_group.main.id]
  tags = {
    Name = "${var.infra_name}-bastion-internal"
  }
}