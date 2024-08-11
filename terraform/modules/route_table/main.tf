resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.internet_cidr_block
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = var.public_route_table_name
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = var.public_subnet_id
  route_table_id = aws_route_table.public.id
}
