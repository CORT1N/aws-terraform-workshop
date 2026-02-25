resource "aws_vpc" "main" {
  cidr_block = local.vpc.cidr
  instance_tenancy = "default"
  tags = {
      Name = local.infra.name
  }
}

resource "aws_subnet" "all" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "esgi-${each.key}"
    Type = each.value.public ? "public" : "private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.infra.name
  }
}

resource "aws_eip" "main" {
  domain = "vpc"
  tags = {
    Name = local.infra.name
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.all["pub-01"].id
  tags = {
    Name = local.infra.name
  }
}

resource "aws_route_table" "main_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${local.infra.name}-private"
  }
}

resource "aws_route_table" "main_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.infra.name}-public"
  }
}

resource "aws_route_table_association" "all" {
    for_each = local.subnets

    subnet_id      = aws_subnet.all[each.key].id
    route_table_id = each.value.public ? aws_route_table.main_public.id : aws_route_table.main_private.id
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
    Name = local.infra.name
  }
}

resource "aws_network_interface" "bastion_internal" {
  subnet_id   = aws_subnet.all["priv-01"].id
  security_groups = [aws_security_group.main.id]
  tags = {
    Name = "${local.infra.name}-bastion-internal"
  }
}