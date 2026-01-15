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

# Set default root password
# WARNING: Change this immediately after first login!
# For production, use SSH keys via environment variable or volume mount
RUN echo 'root:changeme' | chpasswd

# Expose SSH port
# Coolify will map this to a host port automatically
EXPOSE 22

# Health check to ensure SSH is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep sshd || exit 1

# Start SSH server in foreground
# -e: Log to stderr (Docker can capture logs)
CMD ["/usr/sbin/sshd", "-D", "-e"]
