# Ubuntu 
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

# Start Minikube
sudo minikube start --driver=docker --cpus=2 --memory=2048


#________________________________________________________________________


# AMAZON LINUX 2 INSTANCE SCRIPTS
#!/bin/bash

# # Update the system
# sudo yum update -y

# # Install Docker
# sudo amazon-linux-extras install docker -y
# sudo service docker start
# sudo usermod -a -G docker ec2-user
# newgrp docker

# # Install Kubectl
# curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod +x ./kubectl
# sudo mv ./kubectl /usr/local/bin/kubectl

# # Install Minikube
# curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# chmod +x minikube
# sudo mv minikube /usr/local/bin/

# # Start Minikube
# minikube start --driver=docker


