output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.subnet.public_subnet_id
}

output "public_route_table_id" {
  value = module.route_table.public_route_table_id
}

output "public_instance_id" {
  value = module.instances.public_instance_id
}

output "public_instance_public_ip" {
  value = module.instances.public_instance_public_ip
}
