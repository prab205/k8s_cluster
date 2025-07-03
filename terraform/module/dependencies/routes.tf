#Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  # local automatically configured

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name                               = "k8s_public_rt",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

resource "aws_route_table_association" "public-rta" {
  subnet_id      = aws_subnet.k8s_public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public-rtb" {
  subnet_id      = aws_subnet.k8s_public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

