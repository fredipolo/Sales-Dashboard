# ============================================================
# main.tf - Sales Dashboard Infrastructure
# Provisions EC2 instance, Security Group, and Key Pair
# on AWS using Terraform
# ============================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# ============================================================
# AWS Provider - Region configured via variables
# ============================================================
provider "aws" {
  region = var.aws_region
}

# ============================================================
# DATA SOURCE - Get latest Ubuntu 22.04 AMI automatically
# ============================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu official)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================================
# SECURITY GROUP - Controls inbound/outbound traffic
# ============================================================
resource "aws_security_group" "sales_dashboard_sg" {
  name        = "sales-dashboard-sg"
  description = "Security group for Sales Dashboard EC2 instance"

  # Allow SSH access (port 22) from anywhere
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access (port 80) from anywhere
  ingress {
    description = "HTTP web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow app traffic on port 5000 (Flask default)
  ingress {
    description = "Flask application port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sales-dashboard-sg"
    Project     = "Sales Dashboard"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# KEY PAIR - SSH key for EC2 access
# Uses existing public key from local machine
# ============================================================
resource "aws_key_pair" "sales_dashboard_key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)

  tags = {
    Name      = "sales-dashboard-key"
    ManagedBy = "Terraform"
  }
}

# ============================================================
# EC2 INSTANCE - Ubuntu server running the sales dashboard
# ============================================================
resource "aws_instance" "sales_dashboard" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.sales_dashboard_key.key_name
  vpc_security_group_ids = [aws_security_group.sales_dashboard_sg.id]

  # User data script - runs on first boot automatically
  # Installs Docker and deploys the sales dashboard container
  user_data = <<-EOF
    #!/bin/bash
    # Update system packages
    apt-get update -y
    apt-get upgrade -y

    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh

    # Add ubuntu user to docker group
    usermod -aG docker ubuntu

    # Enable and start Docker service
    systemctl enable docker
    systemctl start docker

    # Pull and run the sales dashboard container
    docker pull ${var.docker_image}
    docker run -d \
      --name sales-dashboard \
      --restart always \
      -p 80:5000 \
      ${var.docker_image}
  EOF

  tags = {
    Name        = "sales-dashboard-server"
    Project     = "Sales Dashboard"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
