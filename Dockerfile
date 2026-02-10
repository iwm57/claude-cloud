# Cloud development environment with Python 3.13
# Debian-based for better package compatibility
FROM python:3.13-slim

# Set working directory for projects
WORKDIR /workspace

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    vim \
    nano \
    bash \
    jq \
    # Node.js runtime and package manager
    nodejs \
    npm \
    # For building packages
    build-essential \
    # For kindly-web-search MCP get_content function
    chromium \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install uvx (Python package runner) for MCP stdio servers
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.cargo/bin/uvx /usr/local/bin/uvx || \
    ln -sf /root/.cargo/bin/uvx /usr/local/bin/uvx

# Install z.ai coding helper
RUN npm install -g @z_ai/coding-helper

# Copy self-healing entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Declare volumes for persistent storage
VOLUME ["/root/.claude", "/workspace"]

# Health check - container is healthy if Claude CLI is available
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD command -v claude || exit 1

# Run entrypoint (keeps container alive)
CMD ["/entrypoint.sh"]
