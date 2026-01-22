# Cloud Development Environment for Coolify

A lightweight, containerized development environment optimized for Coolify deployment. Run Claude CLI with Node.js and Python development tools in an isolated workspace.

**Features:**
- **Lightweight:** Alpine Linux base (~150 MB without SSH)
- **Resource-constrained:** 1GB RAM, 3GB disk space per container
- **Pre-installed:** Claude CLI, Node.js, Python, Git, vim, nano
- **Self-healing:** Automatic setup of tools and scripts on container start
- **Persistent storage:** Claude session data and context preserved across redeployments
- **Access via:** Coolify web terminal or docker exec

**Resource Limits:**
- CPU: 1 core
- RAM: 1 GB
- Disk: 3 GB (including base image)

---

## Quick Start

### 1. Deploy to Coolify

#### From Git Repository

1. In Coolify, create a new resource
2. Select **Dockerfile** build pack
3. Connect your `iwm57/claude-cloud` repository
4. Deploy!

#### From Local Dockerfile

```bash
# Build the image
docker build -t claude-cloud:latest .

# Optional: Tag and push to registry
docker tag claude-cloud:latest your-registry/claude-cloud:latest
docker push your-registry/claude-cloud:latest
```

### 2. Configure Environment Variables

In Coolify UI, set these environment variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `GITHUB_TOKEN` | No | Personal access token for gh CLI authentication |
| `SERPER_API_KEY` | No | API key for kindly-web-search MCP server |

### 3. Configure Volume Mounts

For persistence across redeployments, add these volume mounts in Coolify:

| Volume Path | Purpose |
|-------------|---------|
| `/root/.claude` | Claude CLI session data, history, settings |
| `/workspace/context` | Your project context, notes, and scripts |

**Note:** The container automatically creates `/workspace/context/scripts/startup/` for your custom scripts.

### 4. Access the Container

After deployment, access via Coolify web terminal or:

```bash
docker exec -it <container-name> bash
```

---

## Self-Healing Features

The container automatically sets up tools and runs your custom scripts on every start:

### Automatic Setup

1. **gh CLI** - Installed and authenticated if `GITHUB_TOKEN` is provided
2. **uv** - Python package installer, always available
3. **kindly-web-search MCP** - Auto-configured if `SERPER_API_KEY` is provided
4. **Startup scripts** - Any `.sh` files in `/workspace/context/scripts/startup/` are executed automatically

### Using Startup Scripts

Place executable scripts in `/workspace/context/scripts/startup/`:

```bash
# Example: Install chromium cleanup on container start
cat > /workspace/context/scripts/startup/chromium-cleanup.sh << 'EOF'
#!/bin/sh
# This script runs automatically on container start
# See examples/startup-scripts/chromium-cleanup.sh for reference
EOF
chmod +x /workspace/context/scripts/startup/chromium-cleanup.sh
```

**Example scripts are provided in `examples/startup-scripts/`:**
- `chromium-cleanup.sh` - Auto-kill orphaned Chromium processes

---

## Development Workflow

### Starting a New Project

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
```

### Inside the Container

```bash
# Install dependencies
npm install          # Node.js
pip install -r requirements.txt  # Python

# Use Claude for assistance
claude "Debug this error"
claude "Refactor this function"
```

### Cleaning Up

When your project is complete:

1. Go to **Coolify Dashboard** → **Resources**
2. Find your project container
3. Click **Delete** → **Confirm**
4. Container and all data are permanently removed (volume mounts persist unless deleted)

---

## Available Tools

**Pre-installed in every container:**

| Tool | Purpose |
|------|---------|
| Node.js | JavaScript runtime |
| npm | Node.js package manager |
| Python 3.x | Python runtime |
| pip | Python package manager |
| uv | Fast Python package installer (auto-installed) |
| Git | Version control |
| gh CLI | GitHub CLI (auto-installed if GITHUB_TOKEN set) |
| Claude CLI | AI coding assistant |
| vim | Text editor |
| nano | Simple text editor |
| curl | HTTP client |
| bash | Shell |

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

### Volume Mounts (Recommended)

For data to survive redeployments, configure these volume mounts in Coolify:

| Mount Path | Purpose |
|------------|---------|
| `/root/.claude` | Claude session data, history, settings |
| `/workspace/context` | Your persistent context, notes, scripts |

**Without volume mounts:** All data is lost when container redeploys.

**With volume mounts:** Only data in mounted paths persists. `/workspace` (except `/workspace/context`) is ephemeral.

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

---

## Troubleshooting

### Container Won't Start

```bash
# Check logs in Coolify dashboard
# Or via CLI:
docker logs <container-id>
```

### Can't Access Container

1. Verify container is running: `docker ps`
2. Use Coolify web terminal for direct access
3. Or use: `docker exec -it <container-id> bash`

### Out of Space

```bash
# Check disk usage
df -h
du -sh /workspace/*

# Clean caches
npm cache clean --force
pip cache purge
rm -rf ~/.cache
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

**Container Structure:**

```
claude-cloud container
├── /workspace              ← Working directory (ephemeral)
│   └── /context           ← Persistent volume mount
│       └── scripts/
│           └── startup/   ← Your startup scripts
├── /root/.claude          ← Persistent volume mount
│   ├── history.jsonl      ← Conversation history
│   ├── session-env/       ← Session environments
│   └── settings.json      ← Your settings
└── entrypoint.sh          ← Self-healing setup script
```

Each container is:
- **Isolated:** Separate filesystem, processes, network
- **Ephemeral:** Easy to delete and recreate (with volume persistence)
- **Resource-constrained:** Won't affect other projects

---

## Examples

See the `examples/` directory for sample project setups:

- `examples/nodejs-project/` - Simple Express.js API
- `examples/python-project/` - Flask web application
- `examples/startup-scripts/` - Startup scripts for automatic execution

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

The `build-base` package is included for compiling native npm/pip packages. If you don't need it, remove it from the Dockerfile to save ~80 MB.

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
