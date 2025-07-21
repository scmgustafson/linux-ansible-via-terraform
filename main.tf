terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
  required_version = "~> 1.12.0"
}

provider "aws" {
  region = var.aws_region
}

# Generate a throwaway keypair to be used for communication between Ansible and the managed node
resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible_demo_key" {
  key_name   = "ansible-demo-key-${tls_private_key.demo_key.id}"
  public_key = tls_private_key.demo_key.public_key_openssh
}

# Save a local copy for testing
resource "local_file" "cloud_pem" {
  filename        = "${path.module}/cloudtls.pem"
  content         = tls_private_key.demo_key.private_key_pem
  file_permission = "0700"
}

# Provision the nodes starting with the Ansible control node
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "managed_node" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ansible_demo_key.key_name

  tags = {
    Name = "ManagedNode"
  }
}

resource "aws_instance" "control_node" {
  # Explicit dependency to ensure this node is created after the demo node to be managed
  depends_on = [aws_instance.managed_node]

  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ansible_demo_key.key_name

  # Run setup script to install Ansible
  user_data = templatefile("${path.module}/assets/control-user-data.sh",
    {
      private_key = tls_private_key.demo_key.private_key_pem
  })

  tags = {
    Name = "ControlNode"
  }
}

# Ansible Configuration Setup

# Templatize the 'hosts' file using new managed_node DNS on each run
resource "local_file" "ansible_hosts" {
  depends_on = [aws_instance.managed_node]

  content = templatefile("${path.module}/templates/hosts.tmpl",
    {
      ansible_managed_host_dns = aws_instance.managed_node.private_dns
  })
  filename = "${path.module}/ansible/inventory/hosts"
}

# Place all Ansible files onto control_node
resource "null_resource" "upload_ansible_files" {
  depends_on = [aws_instance.control_node, local_file.ansible_hosts]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.demo_key.private_key_pem
    host        = aws_instance.control_node.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/ansible"
    destination = "/tmp/ansible"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/ansible",
      "sudo cp -r /tmp/ansible/* /etc/ansible",
      "sudo chown -R root:root /etc/ansible"
    ]
  }
}

# Temp config for testing ansible is working correctly after provisioning
# Requires a public IP on control_node
resource "null_resource" "ansible_test" {
  depends_on = [aws_instance.control_node, null_resource.upload_ansible_files]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.demo_key.private_key_pem
    host        = aws_instance.control_node.public_ip
  }

  provisioner "remote-exec" {
    inline = [
    "echo 'Waiting for Ansible to become available...'",
    "for i in {1..12}; do command -v ansible >/dev/null && break || sleep 5; done",
    "sudo ansible -m ping all | sudo tee /var/log/ansible-ping.log"
  ]
  }
}
