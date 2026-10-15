ARG UID=1000
ARG GID=1000

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ARG CUDA_INSTALL=false
LABEL cuda=$CUDA_INSTALL

ENV DEBIAN_FRONTEND=noninteractive
# ENV PATH="${HOME}/.local/bin:${PATH}"

RUN apt update && apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    socat \
    iproute2 \
    bubblewrap \
    python3 \
    python3-pip \
    git \
    ripgrep \
  && rm -rf /var/lib/apt/lists/*

ARG LATEX_INSTALL=false
LABEL latex=$LATEX_INSTALL

RUN if [ "$LATEX_INSTALL" = "true" ]; then \
      apt update && \
      apt install -y --no-install-recommends \
        texlive \
        texlive-latex-extra \
        texlive-plain-generic \
        texlive-fonts-recommended \
        texlive-science \
        texlive-bibtex-extra \
        biber \
        latexmk && \
      rm -rf /var/lib/apt/lists/*; \
    fi

ARG NEOVIM_INSTALL=false
LABEL neovim=$NEOVIM_INSTALL

RUN if [ "$NEOVIM_INSTALL" = "true" ]; then \
      apt update && \
      apt install -y --no-install-recommends \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        unzip \
        tar \
        gzip \
        xclip \
        wl-clipboard \
        python3-venv \
        python3-pynvim \
        nodejs \
        npm \
        lua5.1 \
        luarocks && \
      rm -rf /var/lib/apt/lists/* && \
      case "$(dpkg --print-architecture)" in \
        amd64) nvim_arch=x86_64 ;; \
        arm64) nvim_arch=arm64 ;; \
        *) echo "Unsupported architecture for Neovim" >&2; exit 1 ;; \
      esac && \
      curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz" \
        -o /tmp/nvim-linux.tar.gz && \
      mkdir -p /opt/nvim && \
      tar -xzf /tmp/nvim-linux.tar.gz -C /opt/nvim --strip-components=1 && \
      ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim && \
      rm /tmp/nvim-linux.tar.gz; \
    fi

ARG OPENCODE_INSTALL=false
LABEL opencode=$OPENCODE_INSTALL
ENV OPENCODE_INSTALL=${OPENCODE_INSTALL}

ARG CLAUDECODE_INSTALL=false
LABEL claudecode=$CLAUDECODE_INSTALL

ARG CODEX_INSTALL=false
LABEL codex=$CODEX_INSTALL
ENV CODEX_INSTALL=${CODEX_INSTALL}

ARG PI_INSTALL=false
LABEL pi=$PI_INSTALL

RUN cat > /usr/local/bin/docker-entrypoint.sh <<'EOF'
#!/usr/bin/env bash
set -e

# OAuth callback helper (host localhost:1455 -> container :1455 -> loopback :1455)
if [ "${OPENCODE_INSTALL}" = "true" ] || [ "${CODEX_INSTALL}" = "true" ]; then
  socat TCP-LISTEN:1456,fork,reuseaddr TCP:127.0.0.1:1455 &
fi

exec "$@"
EOF

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN if ! getent group ubuntu >/dev/null; then \
      groupadd --gid "${GID}" ubuntu; \
    fi && \
    if ! id -u ubuntu >/dev/null 2>&1; then \
      useradd --uid "${UID}" --gid ubuntu --create-home --shell /bin/bash ubuntu; \
    fi && \
    mkdir -p /home/ubuntu && chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu
ENV HOME=/home/ubuntu
ENV CLAUDE_CONFIG_DIR=/home/ubuntu/.claude
ENV PATH="/home/ubuntu/.local/bin:${PATH}"

ARG UV_INSTALL=false
LABEL uv=$UV_INSTALL
RUN if [ "$UV_INSTALL" = "true" ]; then \
      mkdir -p .config/uv .cache/uv .local/share/uv && \
      curl -fsSL https://astral.sh/uv/install.sh | sh; \
    fi

RUN if [ "$LATEX_INSTALL" = "true" ]; then \
      mkdir -p .config/latexmk; \
    fi

RUN if [ "$NEOVIM_INSTALL" = "true" ]; then \
      mkdir -p .config/nvim .local/share/nvim .local/state/nvim .cache/nvim; \
    fi

RUN if [ "$OPENCODE_INSTALL" = "true" ]; then \
      mkdir -p .config/opencode .cache/opencode .local/share/opencode && \
      curl -fsSL https://opencode.ai/install | env OPENCODE_DISABLE_AUTOUPDATE=1 bash; \
    fi

RUN if [ "$CLAUDECODE_INSTALL" = "true" ]; then \
      mkdir -p .claude .local/share/claude .cache/claude && \
      curl -fsSL https://claude.ai/install.sh | bash; \
    fi

RUN if [ "$CODEX_INSTALL" = "true" ] || [ "$PI_INSTALL" = "true" ]; then \
      mkdir -p .local/bin && \
      export NVM_DIR="$HOME/.nvm" && \
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash && \
      bash -lc '. "$HOME/.nvm/nvm.sh" && nvm install --lts && for bin in node npm npx; do ln -sf "$NVM_BIN/$bin" "$HOME/.local/bin/$bin"; done'; \
    fi

RUN if [ "$CODEX_INSTALL" = "true" ]; then \
      mkdir -p .codex && \
      bash -lc '. "$HOME/.nvm/nvm.sh" && npm install -g @openai/codex && ln -sf "$NVM_BIN/codex" "$HOME/.local/bin/codex"'; \
    fi

RUN if [ "$PI_INSTALL" = "true" ]; then \
      mkdir -p .pi/agent && \
      bash -lc '. "$HOME/.nvm/nvm.sh" && npm install -g --ignore-scripts @earendil-works/pi-coding-agent && ln -sf "$NVM_BIN/pi" "$HOME/.local/bin/pi"'; \
    fi


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
