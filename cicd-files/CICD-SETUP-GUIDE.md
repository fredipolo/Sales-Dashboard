# CI/CD Pipeline Setup Guide

This guide will help you set up the complete CI/CD pipeline for your Sales Dashboard application.

## 📋 Prerequisites

1. ✅ GitHub repository (already done: fredipolo/Sales-Dashboard)
2. ✅ AWS account (you confirmed you have this)
3. 🔲 Docker Hub account (free - we'll set this up)
4. 🔲 AWS EC2 instance (we'll create this)

---

## Part 1: Docker Hub Setup (5 minutes)

### Step 1: Create Docker Hub Account
1. Go to: https://hub.docker.com/signup
2. Create a free account
3. Verify your email

### Step 2: Create Access Token
1. Log in to Docker Hub
2. Go to: Account Settings → Security → Access Tokens
3. Click "New Access Token"
4. Name: "GitHub Actions CI/CD"
5. Permissions: "Read, Write, Delete"
6. Click "Generate"
7. **COPY THE TOKEN** (you won't see it again!)

### Step 3: Add Docker Hub Secrets to GitHub
1. Go to your GitHub repo: https://github.com/fredipolo/Sales-Dashboard
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add these two secrets:

   **Secret 1:**
   - Name: `DOCKER_USERNAME`
   - Value: Your Docker Hub username

   **Secret 2:**
   - Name: `DOCKER_PASSWORD`
   - Value: The access token you just copied

---

## Part 2: AWS EC2 Instance Setup

### Step 1: Launch EC2 Instance
1. Log in to AWS Console: https://console.aws.amazon.com/ec2/
2. Click **"Launch Instance"**
3. Configure:
   - **Name:** sales-dashboard-server
   - **AMI:** Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance type:** t2.micro (Free tier)
   - **Key pair:** Create new key pair
     - Name: `sales-dashboard-key`
     - Type: RSA
     - Format: .pem
     - **Download and save the .pem file!**
   - **Network settings:**
     - Allow SSH (port 22) from "My IP"
     - Allow HTTP (port 80) from "Anywhere"
   - **Storage:** 8 GB (default)
4. Click **"Launch instance"**
5. Wait for instance to be running
6. **Note down the Public IP address**

### Step 2: Connect to EC2 and Install Docker
Open PowerShell and run:

```bash
# Make the key file secure (if on Windows, skip this)
# chmod 400 sales-dashboard-key.pem

# Connect to EC2
ssh -i sales-dashboard-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Once connected, run these commands on the EC2 instance:

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Enable Docker to start on boot
sudo systemctl enable docker

# Exit and reconnect for group changes to take effect
exit

# Reconnect
ssh -i sales-dashboard-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Verify Docker is working
docker --version
docker ps
```

### Step 3: Add AWS Secrets to GitHub
1. Go to: https://github.com/fredipolo/Sales-Dashboard/settings/secrets/actions
2. Add these secrets:

   **Secret 1:**
   - Name: `EC2_HOST`
   - Value: Your EC2 public IP address (e.g., 54.123.45.67)

   **Secret 2:**
   - Name: `EC2_USERNAME`
   - Value: `ubuntu`

   **Secret 3:**
   - Name: `EC2_SSH_KEY`
   - Value: Contents of your .pem file
     - Open `sales-dashboard-key.pem` in Notepad
     - Copy ENTIRE contents (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)
     - Paste into the secret value

---

## Part 3: Deploy the Pipeline

### Step 1: Add Workflow File to Your Repository

1. In your local `sales-dashboard-app` folder, create this structure:
   ```
   .github/
     workflows/
       deploy.yml
   ```

2. Copy the `deploy.yml` file I created into `.github/workflows/deploy.yml`

3. Commit and push:
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Add CI/CD pipeline"
   git push origin main
   ```

### Step 2: Watch the Magic Happen! ✨

1. Go to: https://github.com/fredipolo/Sales-Dashboard/actions
2. You should see your workflow running
3. Click on it to watch the progress
4. It will:
   - ✅ Build Docker image
   - ✅ Push to Docker Hub
   - ✅ Deploy to EC2
   - ✅ Run health check

### Step 3: Access Your Live Application

After the workflow completes:
- Visit: `http://YOUR_EC2_PUBLIC_IP`
- You should see your Sales Dashboard! 🎉

---

## Part 4: Testing the Pipeline

Make a small change to test automatic deployment:

```bash
# Edit app.py - change the total revenue or add a new month
# Then commit and push
git add .
git commit -m "Update sales data"
git push origin main
```

Watch GitHub Actions automatically deploy your changes!

---

## 🔧 Troubleshooting

### Pipeline fails at "Deploy to EC2"
- Check that EC2_SSH_KEY secret contains the full .pem file contents
- Verify EC2 security group allows SSH from GitHub Actions IPs

### Docker pull fails
- Verify DOCKER_USERNAME and DOCKER_PASSWORD secrets are correct
- Check Docker Hub token has read/write permissions

### Can't access application
- Check EC2 security group allows HTTP (port 80) from 0.0.0.0/0
- Verify container is running: `docker ps` on EC2

### Health check fails
- SSH into EC2: `ssh -i sales-dashboard-key.pem ubuntu@YOUR_EC2_IP`
- Check logs: `docker logs sales-dashboard`
- Check if running: `docker ps`

---

## 📊 Pipeline Architecture Diagram

```
Developer
    ↓
  [Git Push to main branch]
    ↓
GitHub Actions Triggered
    ↓
┌─────────────────────────┐
│  Job 1: Build & Push    │
│  - Checkout code        │
│  - Build Docker image   │
│  - Push to Docker Hub   │
└─────────────────────────┘
    ↓
┌─────────────────────────┐
│  Job 2: Deploy          │
│  - SSH to EC2           │
│  - Pull latest image    │
│  - Stop old container   │
│  - Start new container  │
│  - Health check         │
└─────────────────────────┘
    ↓
Application Live on EC2!
```

---

## 🎯 Summary of Secrets Needed

| Secret Name       | Value                          | Where to Get It                |
|-------------------|--------------------------------|--------------------------------|
| DOCKER_USERNAME   | Your Docker Hub username       | hub.docker.com                 |
| DOCKER_PASSWORD   | Docker Hub access token        | hub.docker.com → Security      |
| EC2_HOST          | EC2 public IP                  | AWS EC2 Console                |
| EC2_USERNAME      | ubuntu                         | Default for Ubuntu AMI         |
| EC2_SSH_KEY       | Contents of .pem file          | Downloaded when creating key   |

---

## ✅ Checklist

- [ ] Docker Hub account created
- [ ] Docker Hub secrets added to GitHub
- [ ] EC2 instance launched
- [ ] Docker installed on EC2
- [ ] EC2 secrets added to GitHub
- [ ] Workflow file pushed to repository
- [ ] Pipeline runs successfully
- [ ] Application accessible via browser

---

## Next Steps for Your Assignment

After the pipeline is working:
1. ✅ Take screenshots of the pipeline running
2. ✅ Record your 10-minute walkthrough video
3. ✅ Write your PDF report including:
   - Architecture diagram (included above)
   - Explanation of each component
   - Challenges faced and how you solved them
   - Screenshots of working deployment

Good luck! 🚀
