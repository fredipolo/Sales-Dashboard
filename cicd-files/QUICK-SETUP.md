# CI/CD Quick Setup Checklist

## 🚀 5 Steps to Get Your Pipeline Running

### Step 1: Docker Hub (5 min)
1. Sign up: https://hub.docker.com/signup
2. Create access token: Account Settings → Security → New Access Token
3. Add to GitHub secrets:
   - DOCKER_USERNAME = your username
   - DOCKER_PASSWORD = your token

### Step 2: AWS EC2 (10 min)
1. Launch t2.micro Ubuntu 22.04 instance
2. Create & download key pair (.pem file)
3. Allow ports: 22 (SSH), 80 (HTTP)
4. Note your public IP

### Step 3: Install Docker on EC2 (5 min)
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
exit
```

### Step 4: Add EC2 Secrets to GitHub (2 min)
1. Go to repo → Settings → Secrets → Actions
2. Add:
   - EC2_HOST = your EC2 public IP
   - EC2_USERNAME = ubuntu
   - EC2_SSH_KEY = contents of your .pem file

### Step 5: Push Workflow File (2 min)
```bash
# Copy deploy.yml to .github/workflows/ in your project
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD pipeline"
git push origin main
```

## ✅ Done!
Visit: http://YOUR_EC2_IP to see your live app!

---

## GitHub Secrets Summary

You need 5 secrets total:

| Secret           | Value                    |
|------------------|--------------------------|
| DOCKER_USERNAME  | Docker Hub username      |
| DOCKER_PASSWORD  | Docker Hub token         |
| EC2_HOST         | EC2 public IP            |
| EC2_USERNAME     | ubuntu                   |
| EC2_SSH_KEY      | Full .pem file contents  |

---

## Test Your Pipeline

1. Make a small change to app.py
2. Commit and push
3. Watch GitHub Actions automatically deploy!

```bash
git add .
git commit -m "Test deployment"
git push origin main
```

Go to: https://github.com/fredipolo/Sales-Dashboard/actions
