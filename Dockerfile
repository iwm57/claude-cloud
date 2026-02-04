# Lightweight base for cloud development environment
# Optimized for Coolify deployment with resource constraints
FROM alpine:3.19

# Set working directory for projects
WORKDIR /workspace

# Install dependencies
RUN apk add --no-cache \
    git \
    curl \
    vim \
    nano \
    bash \
    jq \
    # Node.js runtime and package manager
    nodejs \
    npm \
    # Python runtime and package manager
    python3 \
    py3-pip \
    # For building packages
    build-base \
    # For kindly-web-search MCP get_content function
    chromium \
    && rm -rf /var/cache/apk/*

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install z.ai coding helper
RUN npm install -g @z_ai/coding-helper

# Copy self-healing entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Declare volumes for persistent storage
VOLUME ["/root/.claude", "/workspace/context"]

# Health check - container is healthy if Claude CLI is available
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD command -v claude || exit 1

# Run entrypoint (keeps container alive)
CMD ["/entrypoint.sh"]
