#!/bin/sh
# Self-healing entrypoint for claude-cloud container
set -e

echo "==> Claude Cloud Container Initializing..."

# 1. Ensure persistent directories exist
mkdir -p /workspace/context/scripts/startup
mkdir -p /workspace/context/scripts/periodic
echo "==> Persistent directories ready"

# 2. Install gh CLI if GITHUB_TOKEN is provided
if [ -n "$GITHUB_TOKEN" ] && ! command -v gh >/dev/null 2>&1; then
    echo "==> Installing gh CLI..."
    apk add --no-cache gh
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    echo "==> gh CLI installed and authenticated"
fi

# 3. Install uv if not present
if ! command -v uv >/dev/null 2>&1; then
    echo "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc
    echo "==> uv installed"
fi

# 4. Configure z.ai coding-helper if Z_AI_API_KEY is provided
if [ -n "$Z_AI_API_KEY" ] && command -v coding-helper >/dev/null 2>&1; then
    echo "==> Configuring z.ai coding-helper..."
    coding-helper auth glm_coding_plan_global "$Z_AI_API_KEY" && \
    echo "==> z.ai coding-helper configured" || \
    echo "==> z.ai coding-helper configuration skipped"
fi

# 5. Install kindly-web-search MCP if SERPER_API_KEY is provided
if [ -n "$SERPER_API_KEY" ]; then
    # Wait for Claude CLI to be available
    for i in $(seq 1 30); do
        if command -v claude >/dev/null 2>&1; then
            # Check if MCP already configured
            if ! claude mcp list 2>/dev/null | grep -q "kindly-web-search"; then
                echo "==> Installing kindly-web-search MCP..."
                claude mcp add kindly-web-search \
                    --transport stdio \
                    --env SERPER_API_KEY="$SERPER_API_KEY" \
                    -- \
                    uvx --from git+https://github.com/Shelpuk-AI-Technology-Consulting/kindly-web-search-mcp-server \
                    kindly-web-search-mcp-server start-mcp-server && \
                echo "==> kindly-web-search MCP installed" || echo "==> MCP install skipped (may already exist)"
            fi
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

echo "==> Container ready! Claude CLI available."

# Keep container alive with a simple sleep loop
exec sleep infinity
