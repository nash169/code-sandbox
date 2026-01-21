# syntax=docker/dockerfile:1
ARG CUDA_TAG=13.1.0
FROM nvidia/cuda:${CUDA_TAG}-devel-ubuntu24.04


ENV DEBIAN_FRONTEND=noninteractive
# ENV PATH="${HOME}/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    socat \
  && rm -rf /var/lib/apt/lists/*

USER ubuntu
WORKDIR /home/ubuntu
ENV OPENCODE_DISABLE_AUTOUPDATE=1
RUN curl -fsSL https://opencode.ai/install | bash
RUN curl -fsSL https://astral.sh/uv/install.sh | sh

# OAuth callback helper (host localhost:1455 -> container :1455 -> loopback :1455)
USER root
RUN cat > /usr/local/bin/docker-entrypoint.sh <<'EOF'
#!/usr/bin/env bash
set -e
socat TCP-LISTEN:1455,fork,reuseaddr TCP:127.0.0.1:1455 &
exec "$@"
EOF
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
