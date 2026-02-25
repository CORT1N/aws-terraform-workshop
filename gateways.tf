resource "aws_internet_gateway" "int-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "esgi-int-gat-01"
  }
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"

  tags = {
    Name = "esgi-nat-eip-01"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.all["priv-01"].id

  tags = {
    Name = "esgi-nat-gat-01"
  }
}