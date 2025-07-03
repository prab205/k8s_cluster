#VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                               = "k8s_vpc",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

#Public Subnet
resource "aws_subnet" "k8s_public_subnet_a" {
  vpc_id            = aws_vpc.k8s_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block        = "10.0.0.0/26"

  tags = {
    Name                               = "k8s_public_subnet_a",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

#Public Subnet
resource "aws_subnet" "k8s_public_subnet_b" {
  vpc_id            = aws_vpc.k8s_vpc.id
  availability_zone = "ap-south-1b"
  cidr_block        = "10.0.0.128/26"

  tags = {
    Name                               = "k8s_public_subnet_b",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name                               = "k8s_igw",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}

