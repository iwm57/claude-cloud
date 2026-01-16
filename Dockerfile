# Lightweight base for cloud development environment
# Optimized for Coolify deployment with resource constraints:
# - Max 1GB RAM
# - Max 3GB disk space
FROM alpine:3.19

# Set working directory for projects
WORKDIR /workspace

# Install all dependencies in a single layer to minimize size
# Total estimated size: ~226 MB
RUN apk add --no-cache \
    # Version control (~15 MB)
    git \
    # HTTP client (~2 MB)
    curl \
    # Text editors (~11 MB total)
    vim \
    nano \
    # Better shell (~5 MB) - Alpine defaults to ash
    bash \
    # SSH server and client (~8 MB)
    openssh \
    # Node.js runtime and package manager (~45 MB)
    nodejs \
    npm \
    # Python runtime and package manager (~60 MB)
    python3 \
    py3-pip \
    # Clean up package cache (redundant with --no-cache but safe)
    && rm -rf /var/cache/apk/*

# Install Claude CLI globally (~83 MB)
RUN npm install -g @anthropic-ai/claude-code

# Configure SSH server for remote access
RUN ssh-keygen -A && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create startup script to set password from environment variable
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'if [ -n "$ROOT_PASSWORD" ]; then' >> /entrypoint.sh && \
    echo '    echo "root:$ROOT_PASSWORD" | chpasswd' >> /entrypoint.sh && \
    echo '    echo "Root password set from environment variable"' >> /entrypoint.sh && \
    echo 'else' >> /entrypoint.sh && \
    echo '    echo "WARNING: Using default root password"' >> /entrypoint.sh && \
    echo '    echo "root:changeme" | chpasswd' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo 'exec /usr/sbin/sshd -D -e' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose SSH port
# Coolify will map this to a host port automatically
EXPOSE 22

# Health check to ensure SSH is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep sshd || exit 1

# Start SSH server in foreground via entrypoint script
CMD ["/entrypoint.sh"]
