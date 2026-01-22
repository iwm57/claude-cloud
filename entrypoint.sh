#!/bin/sh
# Self-healing entrypoint for claude-cloud container
set -e

echo "==> Claude Cloud Container Initializing..."

# 1. Set root password from environment
if [ -n "$ROOT_PASSWORD" ]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo "==> Root password set from environment variable"
else
    echo "root:changeme" | chpasswd
    echo "==> WARNING: Using default root password"
fi

# 2. Ensure persistent directories exist
mkdir -p /workspace/context/scripts/startup
mkdir -p /workspace/context/scripts/periodic
echo "==> Persistent directories ready"

# 3. Install gh CLI if GITHUB_TOKEN is provided
if [ -n "$GITHUB_TOKEN" ]; then
    if ! command -v gh >/dev/null 2>&1; then
        echo "==> Installing gh CLI..."
        apk add --no-cache curl
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/community gh
    fi

    # Authenticate gh CLI
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    echo "==> gh CLI installed and authenticated"
fi

# 4. Install uv if not present
if ! command -v uv >/dev/null 2>&1; then
    echo "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc
    echo "==> uv installed"
fi

# 5. Install kindly-web-search MCP if SERPER_API_KEY is provided
if [ -n "$SERPER_API_KEY" ] && [ ! -f /root/.claude/mcp_config.json ]; then
    echo "==> Installing kindly-web-search MCP..."
    # Wait for Claude CLI to be available
    for i in $(seq 1 30); do
        if command -v claude >/dev/null 2>&1; then
            # Add MCP server
            claude mcp add kindly-web-search \
                --transport stdio \
                --env SERPER_API_KEY="$SERPER_API_KEY" \
                -- \
                uvx --from git+https://github.com/Shelpuk-AI-Technology-Consulting/kindly-web-search-mcp-server \
                kindly-web-search-mcp-server start-mcp-server && \
            echo "==> kindly-web-search MCP installed" && \
            break
        fi
        sleep 1
    done
fi

# 6. Run startup scripts from persistent storage
if [ -d /workspace/context/scripts/startup ]; then
    echo "==> Running startup scripts..."
    for script in /workspace/context/scripts/startup/*.sh; do
        if [ -f "$script" ]; then
            echo "  -> Running $(basename "$script")"
            sh "$script"
        fi
    done
fi

# 7. Start chromium cleanup script if it exists
if [ -f /usr/local/bin/clean-chromium.sh ]; then
    nohup /usr/local/bin/clean-chromium.sh >> /var/log/chromium-clean.log 2>&1 &
    echo "==> Chromium cleanup script started"
fi

echo "==> SSH server starting on port 3000..."
exec /usr/sbin/sshd -D -e
