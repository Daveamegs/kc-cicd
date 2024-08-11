variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  # default     = "ami-0c38b837cd80f13bb" # Ubuntu
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "local_ip" {
  description = "IP address to allow SSH access from"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
  default     = "webserver-pem-key-pair"
}

variable "private_ssh_key_path" {
  description = "Path to private ssh key pair"
}
