# Quick Start Guide

Get your cloud development environment running on Coolify in 5 minutes.

## Step 1: Push to Git Repository

```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Cloud development environment"

# Push to GitHub/GitLab
git remote add origin https://github.com/yourusername/cloud-dev-env.git
git branch -M main
git push -u origin main
```

## Step 2: Deploy to Coolify

1. **Log in to your Coolify dashboard**

2. **Create new resource:**
   - Click **Resources** → **New Resource**
   - Select **Docker Compose** as build pack

3. **Connect repository:**
   - Choose your Git provider (GitHub/GitLab)
   - Select the repository you just pushed
   - Select branch: `main`

4. **Configure environment variables (IMPORTANT):**
   - Go to **Environment Variables** section
   - Add: `ROOT_PASSWORD` → Your secure password
   - (Optional) Add: `PROJECT_NAME` → `my-first-project`

5. **Deploy:**
   - Click **Deploy**
   - Wait for build to complete (~2-3 minutes)

## Step 3: Find Your SSH Port

1. In Coolify, go to your deployed resource
2. Look for the port mapping (e.g., `30001:22`)
3. Note the **host port** (first number, e.g., `30001`)

## Step 4: Connect via SSH

```bash
# Replace with your actual values
ssh -p 30001 root@your-coolify-server-ip

# Enter the password you set in ROOT_PASSWORD
```

**Example:**
```bash
ssh -p 30001 root@coolify.example.com
```

## Step 5: Verify Everything Works

Once connected:

```bash
# Check Node.js
node --version

# Check Python
python3 --version

# Check Claude CLI
claude --version

# Check disk space
df -h

# Check available memory
free -h
```

## Step 6: Start Your First Project

```bash
# Navigate to workspace
cd /workspace

# Option A: Clone existing project
git clone https://github.com/username/project.git .

# Option B: Try the examples
cp -r /path/to/examples/nodejs-project/* .
npm install
npm start

# Option C: Create new project
npm init -y
# Or
python -m venv venv
```

## What's Next?

- **Read the full [README.md](README.md)** for detailed documentation
- **Check out examples** in `examples/` directory
- **Use Claude CLI** for assistance: `claude "Help me build a web API"`
- **Create multiple containers** for different projects

## Cleaning Up

When you're done with a project:

1. Go to **Coolify Dashboard** → **Resources**
2. Find your project container
3. Click **Delete** → **Confirm**

Everything is permanently removed - perfect for ephemeral development!

## Troubleshooting

**Can't connect via SSH?**
- Check Coolify logs for container status
- Verify the port number
- Ensure firewall allows the port
- Try: `ssh -vvv -p PORT root@HOST`

**Container won't start?**
- Check Coolify build logs
- Verify docker-compose.yml syntax
- Ensure environment variables are set

**Out of space?**
- Run: `npm cache clean --force`
- Run: `pip cache purge`
- Check: `df -h`

## Need Help?

- Check [README.md](README.md) for detailed documentation
- Review Coolify logs in dashboard
- Check container logs: `docker logs <container-id>`
