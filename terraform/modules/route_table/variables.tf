variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "internet_cidr_block" {
  description = "Internet routing IPv4 cidr block"
  type        = string
  default     = "0.0.0.0/0"
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "public_route_table_name" {
  description = "Name of public route table"
  type        = string
  default     = "PublicRouteTable"
}
