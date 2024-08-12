# AUTOMATING CI/CD PIPELINE WITH GITHUB ACTIONS: DEPLOYING TO MINIKUBE ON AWS EC2 VIA TERRAFORM

## INTRODUCTION

In today's rapidly evolving software development landscape, continuous integration and continuous deployment (CI/CD) have become essential practices for delivering reliable, high-quality applications at speed. Leveraging modern tools and platforms, such as GitHub Actions and Terraform, allows developers to automate their deployment pipelines efficiently. This task involves setting up a CI/CD pipeline with GitHub Actions to automatically deploy code from a GitHub repository to a Minikube cluster running on an EC2 instance, which is provisioned using Terraform. This approach not only streamlines the deployment process but also ensures consistency and scalability in managing infrastructure and application deployments.

## PREREQUISITE

Below are the things you need to have installed and available already.

- Terraform CLI
- AWSCLI
- AWS Account (Configured locally)
- Github Account
- Minikube
- Kubectl

## STEP 1 - CREATE GITHUB REPOSITORY

Logged in to github and created a repository, named it kc-cicd and cloned the repo locally unto my workspace using ssh.

```bash
git clone
```

## STEP 2 - ADD APPLICATION CODE

Added python application code I created for the previous task. The app was built with flask.

`app/app.py`

```bash
from flask import Flask


app = Flask(__name__)

# Route Traffic to Index
@app.route("/")
def index():
    return "Hello, Welcome to KodeCamp DevOps Bootcamp! New"


# Run App
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

```

## STEP 3 - CREATE KUBERNETES MANIFESTS

I created the kubernetes manifest files, `deployment.yaml` and `service.yaml`.

`k8s/deployment.yaml`

```bash

apiVersion: apps/v1
kind: Deployment
metadata:
  name: kc-minikube-app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kc-kube-app
  template:
    metadata:
      labels:
        app: kc-kube-app
    spec:
      containers:
      - name: kc-minikube-app-deployment
        image: daveamegs/kc-kube-app
        ports:
        - containerPort: 8000
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"

```

`k8s/service.yaml`

```bash
apiVersion: v1
kind: Service
metadata:
  name: kc-minikube-app-service
spec:
  selector:
    app: kc-kube-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: ClusterIP

```

## STEP 4 - CREATE GITHUB ACTIONS WORKFLOWS

Created an empty github actions workflows manifest file called `deploy.yml`.

## STEP 5 - CREATE TERRAFORM MODULES

After I created the Terraform modules.

- VPC MODULE
  `terraform/modules/vpc/main.tf`

  ```bash
  resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block

    tags = {
      Name = var.vpc_name
    }
  }

  ```

  `terraform/modules/vpc/variables.tf`

  ```bash
  variable "vpc_name" {
    description = "Name of the VPC"
    type        = string
    default     = "KCVPC"
  }

  variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
  }

  ```

  `terraform/modules/vpc/outputs.tf`

  ```bash
  output "vpc_id" {
    value = aws_vpc.vpc.id
  }

  output "vpc_cidr_block" {
    value = var.vpc_cidr_block
  }

  ```

- SUBNET MODULE
  `terraform/modules/subnets/main.tf`

  ```bash
  resource "aws_subnet" "public" {
    vpc_id                  = var.vpc_id
    cidr_block              = var.public_cidr_block
    availability_zone       = var.public_availability_zone
    map_public_ip_on_launch = true

    tags = {
      Name = var.public_subnet_name
    }
  }

  ```

  `terraform/modules/subnets/variables.tf`

  ```bash
  variable "vpc_id" {
    description = "VPC ID"
    type        = string
  }

  variable "public_subnet_name" {
    description = "Name of the public subnet"
    type        = string
    default     = "PublicSubnet"
  }

  variable "public_cidr_block" {
    description = "CIDR block for the public subnet"
    type        = string
    default     = "10.0.1.0/24"
  }

  variable "public_availability_zone" {
    description = "Availability zone for the public subnet"
    type        = string
    default = "eu-west-1a"
  }

  ```

  `terraform/modules/subnets/outputs.tf`

  ```bash
  output "public_subnet_id" {
    value = aws_subnet.public.id
  }

  ```

- SECURITY GROUP MODULE
  `terraform/modules/security_groups/main.tf`

  ```bash
  resource "aws_security_group" "public" {
    name        = var.public_sg_name
    description = "Security group for public instances"
    vpc_id      = var.vpc_id

    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.internet_cidr_block]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.internet_cidr_block]
    }

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.local_ip]
    }

    ingress {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.internet_cidr_block]
    }

    tags = {
      Name = "PublicSecurityGroup"
    }
  }

  ```

  `terraform/modules/security_groups/variables.tf`

  ```bash
  variable "vpc_id" {
    description = "VPC ID"
    type        = string
  }

  variable "internet_cidr_block" {
    description = "public internet routing IPv4 cidr block"
    type        = string
  }

  variable "local_ip" {
    description = "IP address to allow SSH access from"
    type        = string
  }

  variable "public_sg_name" {
    description = "Name of public security group"
    type        = string
    default     = "PublicSG"
  }

  ```

  `terraform/modules/security_groups/outputs.tf`

  ```bash
  output "public_sg_id" {
    value = aws_security_group.public.id
  }

  ```

- ROUTE TABLE MODULE
  `terraform/modules/route_table/main.tf`

  ```bash
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

  ```

  `terraform/modules/route_table/variables.tf`

  ```bash
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

  ```

  `terraform/modules/route_table/outputs.tf`

  ```bash
  output "public_route_table_id" {
    value = aws_route_table.public.id
  }

  output "internet_cidr_block" {
    value = var.internet_cidr_block
  }

  ```

- INTERNET GATEWAY MODULE
  `terraform/modules/internet_gateway/main.tf`

  ```bash
  resource "aws_internet_gateway" "main" {
    vpc_id = var.vpc_id

    tags = {
      Name = var.igw_name
    }
  }

  ```

  `terraform/modules/internet_gateway/variables.tf`

  ```bash
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

  ```

  `terraform/modules/internet_gateway/outputs.tf`

  ```bash
  output "public_route_table_id" {
    value = aws_route_table.public.id
  }

  output "internet_cidr_block" {
    value = var.internet_cidr_block
  }

  ```

- EC2 INSTANCE MODULE
  `terraform/modules/instances/main.tf`

  ```bash
  resource "aws_instance" "public_instance" {
    ami                         = var.ami
    instance_type               = var.instance_type
    subnet_id                   = var.public_subnet_id
    vpc_security_group_ids      = [var.public_sg_id]
    associate_public_ip_address = true
    key_name                    = var.key_name

    # user_data = file("${path.module}/scripts/install_minikube.sh")

    tags = {
      Name = var.public_instance_name
    }

    provisioner "file" {
      source      = "${path.module}/scripts/install_minikube.sh"
      destination = "/tmp/install_minikube.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/install_minikube.sh",
        "/tmp/install_minikube.sh"
      ]
    }

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_ssh_key_path)
      host        = self.public_ip
    }

  }

  ```

  `terraform/modules/instances/variables.tf`
  ```bash
  variable "ami" {
    description = "AMI ID for the EC2 instances"
    type        = string
  }

  variable "instance_type" {
    description = "Instance type for the EC2 instances"
    type        = string
  }

  variable "public_subnet_id" {
    description = "Public subnet ID"
    type        = string
  }

  variable "private_ssh_key_path" {
    description = "Path to private ssh key pair"
    type        = string
  }

  variable "public_sg_id" {
    description = "Public security group ID"
    type        = string
  }

  variable "public_instance_name" {
    description = "Public instance name"
    type        = string
    default     = "KCWebServer"
  }

  variable "key_name" {
    description = "Key pair name"
    type        = string
  }

  ```

  `terraform/modules/instances/outputs.tf`
  ```bash
  output "public_instance_id" {
    value = aws_instance.public_instance.id
  }

  output "public_instance_public_ip" {
    value = aws_instance.public_instance.public_ip
  }

  ```

- SHELL SCRIPTS
  `terraform/modules/instances/scripts/install_minikube.sh`
  ```bash
  #!/bin/bash
  # Update the system
  sudo apt-get update -y

  # Install Docker
  sudo apt-get install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER

  # Install conntrack package (required by Minikube)
  sudo apt-get install -y conntrack

  # Install Kubectl
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl

  # Install Minikube
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube
  sudo mv minikube /usr/local/bin/

  ```

- EXECUTING TERRAFORM COMMANDS
  I ran `terraform init`.
  After successful initialization, I ran `terraform plan -out tfplan.json` to plan the intended infrastructures before applying with `terraform apply "tfplan.json"`.

  After successful testing, I destroyed the infrastructure with the command `terraform destroy`.

## STEP 6 - ACCESS THE MINIKUBE CLUSTER
I ran `minikube start --driver=docker` and then change the `kubectl` context to minikube with the following command `kubectl config use-context minikube`.

## STEP 7 - UPDATE GITHUB ACTIONS WORKFLOW
I created the events and actions to trigger automatic build with docker and automatic deployment on minikube running on AWS EC2 instance. This automatic event triggers when there is a push to the `main` branch of the repository.

`.github/workflows/deploy.yml`

```bash
name: KC CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Log in to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/kc-kube-app:latest .
          docker push ${{ secrets.DOCKER_USERNAME }}/kc-kube-app:latest

      - name: Deploy to Kubernetes
        env:
          INSTANCE_PUBLIC_IP: ${{ secrets.INSTANCE_PUBLIC_IP }}
          SSH_PEM_KEY: ${{ secrets.SSH_PEM_KEY }}
        run: |
          echo "${SSH_PEM_KEY}" > ssh_key_pair.pem
          chmod 600 ssh_key_pair.pem
          ssh -o StrictHostKeyChecking=no -i ssh_key_pair.pem ubuntu@${INSTANCE_PUBLIC_IP} << "EOF"
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
          EOF

```
