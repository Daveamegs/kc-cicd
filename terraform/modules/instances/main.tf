resource "aws_instance" "public_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.public_sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = file("${path.module}/scripts/install_minikube.sh")

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
