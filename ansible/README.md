# Ansible Configuration Management - Sales Dashboard

## Overview
This Ansible project automates the full configuration of the Sales Dashboard
server. It installs Docker, configures it to start on boot, and deploys
the containerized Flask application automatically.

## Structure
```
ansible/
├── site.yml              # Master playbook - runs all roles
├── inventory.ini         # Target server definitions
└── roles/
    ├── docker/
    │   └── tasks/
    │       └── main.yml  # Installs & configures Docker
    └── app/
        └── tasks/
            └── main.yml  # Deploys the sales dashboard container
```

## Prerequisites
- Ansible installed on your control machine
- SSH access to the target EC2 server
- SSH key at `~/.ssh/id_ed25519`

## Install Ansible (on Ubuntu/Mac)
```bash
sudo apt update
sudo apt install ansible -y

# Install Docker community collection
ansible-galaxy collection install community.docker
```

## Usage

### 1. Test connection to server
```bash
ansible -i inventory.ini all -m ping
```

### 2. Run the full playbook
```bash
ansible-playbook -i inventory.ini site.yml
```

### 3. Run only Docker installation
```bash
ansible-playbook -i inventory.ini site.yml --tags docker
```

### 4. Run only app deployment
```bash
ansible-playbook -i inventory.ini site.yml --tags app
```

## Automation Flow
```
ansible-playbook site.yml
        ↓
[Docker Role]
  - Update apt packages
  - Install Docker dependencies
  - Add Docker GPG key & repository
  - Install Docker Engine
  - Enable Docker on boot ← key requirement
  - Add ubuntu user to docker group
        ↓
[App Role]
  - Pull fredipolodev/sales-dashboard:latest from Docker Hub
  - Stop & remove any existing container
  - Deploy container (port 80:5000, restart always)
  - Health check - verify app is responding
        ↓
✅ Sales Dashboard live at http://44.222.224.140
```

## What Each Role Does

### Docker Role
Automates complete Docker installation from scratch:
- Installs all system dependencies
- Adds official Docker repository
- Installs Docker CE (Community Edition)
- Configures Docker to **automatically start on system boot**
- Grants the ubuntu user permission to run Docker without sudo

### App Role  
Automates container lifecycle management:
- Pulls the latest image from Docker Hub
- Handles clean redeployment (stop → remove → redeploy)
- Sets `restart_policy: always` so container survives reboots
- Performs health check to confirm successful deployment
