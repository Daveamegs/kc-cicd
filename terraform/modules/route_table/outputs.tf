output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "internet_cidr_block" {
  value = var.internet_cidr_block
}