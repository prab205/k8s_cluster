#Security Group for Load Balancer 
resource "aws_security_group" "collective_sg" {
  name        = "k8s_sg"
  description = "Security group for k8s instances"
  vpc_id      = aws_vpc.k8s_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.source_cidr_block
    }
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = var.source_cidr_block
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 30000
    to_port     = 32767
    protocol    = "udp"
    cidr_blocks = var.source_cidr_block
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name                               = "k8s_sg",
    "kubernetes.io/cluster/kubernetes" = "owned"
  }
}