# Terraform Infrastructure - Sales Dashboard

## Overview
This Terraform configuration automates the provisioning of AWS infrastructure
for the Sales Dashboard application. It creates:

- **EC2 Instance** (t2.micro - Free Tier) running Ubuntu 22.04
- **Security Group** with SSH (22), HTTP (80), and Flask (5000) access
- **Key Pair** for SSH authentication
- **User Data Script** that auto-installs Docker and deploys the container on boot

## Prerequisites
- Terraform v1.0+
- AWS CLI configured (`aws configure`)
- SSH key pair at `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`

## Files
| File | Purpose |
|------|---------|
| `main.tf` | Core infrastructure resources |
| `variables.tf` | Input variable definitions |
| `terraform.tfvars` | Your actual variable values |
| `outputs.tf` | Useful info displayed after deployment |

## Usage

### 1. Initialise Terraform
```bash
terraform init
```

### 2. Preview what will be created
```bash
terraform plan
```

### 3. Deploy the infrastructure
```bash
terraform apply
```
Type `yes` when prompted.

### 4. Get your app URL
After deployment, Terraform will output:
- Public IP address
- App URL (http://your-ip)
- SSH command to connect

### 5. Destroy infrastructure (when done)
```bash
terraform destroy
```

## Automation Flow
```
terraform apply
      ↓
AWS Security Group created (ports 22, 80, 5000)
      ↓
SSH Key Pair registered
      ↓
EC2 Instance launched (Ubuntu 22.04, t2.micro)
      ↓
User Data script runs on first boot:
  - Updates system
  - Installs Docker
  - Pulls sales-dashboard image from Docker Hub
  - Runs container on port 80
      ↓
App live at http://<public-ip>
```
