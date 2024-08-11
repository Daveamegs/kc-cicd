resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id
  subnet_ids = [var.public_subnet_id]

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.local_ip
  }

  tags = {
    Name = var.public_nacl_name
  }
}

