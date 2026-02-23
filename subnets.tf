resource "aws_subnet" "all" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "esgi-sub-${each.key}"
    Type = each.value.public ? "public" : "private"
  }
}

resource "aws_route_table" "priv-routing" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "esgi-priv-routing-01"
  }
}

resource "aws_route_table" "pub-routing" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int-gw.id
  }

  tags = {
    Name = "esgi-pub-routing-01"
  }
}

resource "aws_route_table_association" "routing-association" {
    for_each = local.subnets

    subnet_id      = aws_subnet.all[each.key].id
    route_table_id = each.value.public ? aws_route_table.pub-routing.id : aws_route_table.priv-routing.id
}