FROM --platform=linux/amd64 ubuntu:latest AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV TZ=Europe/Luxembourg \
    DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/bash \
    # Compile bytecode for faster startup
    UV_COMPILE_BYTECODE=1 \
    # Copy files rather than symlink them
    UV_LINK_MODE=copy \
    # Protocol buffers setup
    PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python \
    UV_PROJECT_ENVIRONMENT="/venv" \
    PATH="$UV_PROJECT_ENVIRONMENT/bin:$PATH"

# Install necessary packages and clean up
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
      git wget curl bash libgl1 software-properties-common  gcc \
      multitail\
      automake autotools-dev fuse g++ libcurl4-gnutls-dev \
      libfuse-dev libssl-dev libxml2-dev make pkg-config kmod locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y python3 python3-venv python3-pip
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin/:$PATH"

FROM base AS builder
WORKDIR /app

# Copy only the lock and project definition files first to leverage caching
COPY uv.lock pyproject.toml .python-version .env /app/

# Install only the dependencies first (no project code), using cache mounts for uv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev --verbose

COPY document_manager /app/document_manager
COPY README.md /app/README.md

# Install the project itself
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --frozen --no-dev

FROM base
COPY --from=builder $UV_PYTHON_INSTALL_DIR $UV_PYTHON_INSTALL_DIR
COPY --from=builder $UV_PROJECT_ENVIRONMENT $UV_PROJECT_ENVIRONMENT
COPY --from=builder  /app /app

WORKDIR /app

# Copy the fully built application from the builder stage
ENV PATH="/app/.venv/bin:$PATH"
ENV UV_NO_SYNC=1

EXPOSE 8000

CMD ["uv", "run", "document_manager/app.py"]
