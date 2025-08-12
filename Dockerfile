# Multi-stage build for AI Content Filter
# This creates a minimal final image with just the binary

# Build stage
FROM rust:1.75-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy project files
COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY config ./config

# Build the application in release mode
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from builder
COPY --from=builder /app/target/release/ai-content-filter /usr/local/bin/ai-filter

# Copy default configuration
COPY --from=builder /app/config /opt/ai-filter/config

# Create a non-root user
RUN useradd -m -u 1000 filter && \
    chmod +x /usr/local/bin/ai-filter

# Switch to non-root user
USER filter

# Set working directory
WORKDIR /home/filter

# Default command
ENTRYPOINT ["ai-filter"]
CMD ["--help"]