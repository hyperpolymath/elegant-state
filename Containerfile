# SPDX-License-Identifier: AGPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
#
# Containerfile - Multi-stage build for elegant-STATE
# Compatible with Podman and Docker (OCI-compliant)

# =============================================================================
# Stage 1: Builder
# =============================================================================
FROM docker.io/library/rust:1.83-slim-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy source files
# Note: .archive contains the Rust source code
COPY .archive/Cargo.toml .archive/Cargo.lock ./
COPY .archive/src ./src

# Build release binary
RUN cargo build --release

# =============================================================================
# Stage 2: Runtime
# =============================================================================
FROM docker.io/library/debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash elegant

WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /build/target/release/elegant-state /app/elegant-state

# Set ownership
RUN chown -R elegant:elegant /app

# Switch to non-root user
USER elegant

# Default data directory
ENV ELEGANT_STATE_DATA_DIR=/app/data
RUN mkdir -p /app/data

# Expose GraphQL API port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command
ENTRYPOINT ["/app/elegant-state"]
CMD ["serve", "--host", "0.0.0.0", "--port", "8080"]

# =============================================================================
# Labels (OCI Image Spec)
# =============================================================================
LABEL org.opencontainers.image.title="elegant-STATE"
LABEL org.opencontainers.image.description="Local-first state graph for multi-agent orchestration"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.authors="Jonathan D.A. Jewell <hyperpolymath@proton.me>"
LABEL org.opencontainers.image.url="https://github.com/hyperpolymath/elegant-STATE"
LABEL org.opencontainers.image.source="https://github.com/hyperpolymath/elegant-STATE"
LABEL org.opencontainers.image.licenses="MIT OR AGPL-3.0-or-later"
