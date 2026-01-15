# Cloud Development Environment for Coolify

A lightweight, containerized development environment optimized for Coolify deployment. Run Claude CLI with Node.js and Python development tools in an isolated workspace.

**Features:**
- **Lightweight:** Alpine Linux base (~234 MB total, ~2.7 GB free for projects)
- **Resource-constrained:** 1GB RAM, 3GB disk space per container
- **Pre-installed:** Claude CLI, Node.js, Python, Git, vim, nano
- **SSH access:** Secure remote terminal access
- **One container per project:** Easy cleanup when done

**Resource Limits:**
- CPU: 1 core
- RAM: 1 GB
- Disk: 3 GB (including base image)

---

## Quick Start

### 1. Deploy to Coolify

#### Option A: From Git Repository

1. Push this repository to GitHub/GitLab
2. In Coolify, create a new resource
3. Select **Docker Compose** build pack
4. Connect your repository
5. Deploy!

#### Option B: From Local Dockerfile

```bash
# Build the image
docker build -t dev-environment:latest .

# Optional: Tag and push to registry
docker tag dev-environment:latest your-registry/dev-environment:latest
docker push your-registry/dev-environment:latest
```

### 2. Configure Environment Variables

In Coolify UI, set these environment variables for better security:

- `ROOT_PASSWORD`: Your secure SSH password (required)
- `PROJECT_NAME`: Optional identifier for your project

### 3. Connect via SSH

After deployment:

1. Find the assigned SSH port in Coolify dashboard
2. Connect using:
   ```bash
   ssh -p <assigned-port> root@<your-coolify-server-ip>
   ```
3. Enter your password (from `ROOT_PASSWORD` env var)

**Example:**
```bash
ssh -p 30001 root@coolify.example.com
```

---

## Development Workflow

### Starting a New Project

```bash
# Deploy new container via Coolify (one per project)
# Each container gets unique volume and port
```

### Inside the Container

```bash
# You're in /workspace - your project directory
cd /workspace

# Clone an existing project
git clone https://github.com/user/project.git .

# Or start a new project
npm init -y          # Node.js
# OR
python -m venv venv  # Python virtual environment

# Use Claude CLI (already installed)
claude "Help me set up a Node.js project"

# Install dependencies
npm install          # Node.js
pip install -r requirements.txt  # Python
```

### Testing and Development

```bash
# Node.js project
node index.js
npm test
npm run build

# Python project
python main.py
pip install pytest
pytest

# Use Claude for assistance
claude "Debug this error"
```

### Cleaning Up

When your project is complete:

1. Go to **Coolify Dashboard** → **Resources**
2. Find your project container
3. Click **Delete** → **Confirm**
4. Container and all data are permanently removed

---

## Available Tools

**Pre-installed in every container:**

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | (Alpine current) | JavaScript runtime |
| npm | (Alpine current) | Node.js package manager |
| Python | 3.x | Python runtime |
| pip | (Alpine current) | Python package manager |
| Git | (Alpine current) | Version control |
| Claude CLI | Latest | AI coding assistant |
| vim | (Alpine current) | Text editor |
| nano | (Alpine current) | Simple text editor |
| curl | (Alpine current) | HTTP client |
| bash | (Alpine current) | Shell |

**Check versions:**
```bash
node --version
npm --version
python3 --version
pip --version
git --version
claude --version
```

---

## Storage and Persistence

### Volume Mounts

Each container gets a unique persistent volume at `/workspace`:

- Data survives container restarts
- Data persists until you delete the resource in Coolify
- Each project container has isolated storage

### Disk Usage

```bash
# Check available space
df -h

# Check workspace size
du -sh /workspace

# Clean up if needed
npm cache clean --force   # Node.js
pip cache purge           # Python
```

### Automatic Cleanup (Optional)

Enable in Coolify:
1. Go to **Server** → **Configuration** → **Advanced**
2. Set **Docker Cleanup Threshold** (e.g., 80%)
3. Set **Docker Cleanup Frequency** (cron expression)

---

## Security Best Practices

### Initial Setup

1. **Change the default password:**
   - Set `ROOT_PASSWORD` environment variable in Coolify UI
   - Never use the default `changeme` password

2. **Use SSH keys (recommended):**
   ```bash
   # Generate SSH key pair
   ssh-keygen -t ed25519 -C "your-email@example.com"

   # Add public key to container
   # In Coolify, add SSH_PUBLIC_KEY environment variable:
   # ssh-rsa AAAAB3... your-email@example.com
   ```

3. **Restrict access by IP:**
   - Configure firewall rules in Coolify
   - Only allow SSH from your IP address

### SSH Keys Setup (Advanced)

Modify `Dockerfile` to support SSH keys:

```dockerfile
# Replace password authentication section with:
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo "${SSH_PUBLIC_KEY}" >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
```

Then set `SSH_PUBLIC_KEY` environment variable in Coolify.

---

## Optimization Tips

### If You Need More Space

1. **Remove unnecessary packages** (edit Dockerfile):
   - Comment out `build-base` if not compiling native modules
   - Remove editors you don't use (vim or nano)

2. **Clean package caches:**
   ```bash
   npm cache clean --force
   pip cache purge
   rm -rf ~/.cache
   ```

3. **Clean project dependencies:**
   ```bash
   rm -rf node_modules/
   npm install --production
   ```

### If You Need Native Modules

Uncomment in Dockerfile:
```dockerfile
# Add to apk add line:
build-base \
python3-dev \
```

This adds ~80 MB but enables compiling native npm/pip packages.

---

## Troubleshooting

### Container Won't Start

```bash
# Check logs in Coolify dashboard
# Or via CLI:
docker logs <container-id>
```

### Can't Connect via SSH

1. Verify container is running: `docker ps`
2. Check SSH port mapping in Coolify
3. Ensure firewall allows the port
4. Try with verbose mode: `ssh -vvv -p <port> root@<host>`

### Out of Space

```bash
# Check disk usage
df -h
du -sh /workspace/*

# Clean caches
npm cache clean --force
pip cache purge

# If desperate, remove node_modules and reinstall
rm -rf node_modules
npm install
```

### Claude CLI Not Working

```bash
# Check installation
which claude
npm list -g @anthropic-ai/claude-code

# Reinstall if needed
npm install -g @anthropic-ai/claude-code
```

---

## Architecture

**One Container Per Project:**

```
Coolify Server
├── project-alpha (1GB RAM, 3GB disk)
│   ├── SSH Port: 30001
│   ├── Volume: project-data-abc123
│   └── Workspace: /workspace
│
├── project-beta (1GB RAM, 3GB disk)
│   ├── SSH Port: 30002
│   ├── Volume: project-data-def456
│   └── Workspace: /workspace
│
└── project-gamma (1GB RAM, 3GB disk)
    ├── SSH Port: 30003
    ├── Volume: project-data-ghi789
    └── Workspace: /workspace
```

Each container is:
- **Isolated:** Separate filesystem, processes, network
- **Ephemeral:** Easy to delete and recreate
- **Resource-constrained:** Won't affect other projects

---

## Examples

See the `examples/` directory for sample project setups:

- `examples/nodejs-project/` - Simple Express.js API
- `examples/python-project/` - Flask web application

---

## Support

For issues or questions:

1. Check Coolify logs in dashboard
2. Review container logs: `docker logs <container-id>`
3. Verify resource limits in Coolify UI
4. Check disk space: `df -h`

---

## License

MIT License - Feel free to modify and use for your own development workflows.
