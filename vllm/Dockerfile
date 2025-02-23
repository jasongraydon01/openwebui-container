# vLLM Dockerfile for Ubuntu 24.04 with CUDA 12.8

ARG CUDA_VERSION=12.8
ARG PYTHON_VERSION=3.12

FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv \
        git curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv for faster pip installs
RUN --mount=type=cache,target=/root/.cache/uv \
    python3 -m pip install uv

# Upgrade to GCC 10 (optional, might not be necessary with CUDA 12.8)
# RUN apt-get install -y gcc-10 g++-10
# RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 110 --slave /usr/bin/g++ g++ /usr/bin/g++-10

WORKDIR /workspace

# Copy and install common requirements
COPY requirements-common.txt requirements-common.txt
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system -r requirements-common.txt

# Copy and install CUDA-specific requirements
COPY requirements-cuda.txt requirements-cuda.txt
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system -r requirements-cuda.txt

# Copy vLLM code
COPY..

# Install vLLM
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system.

# Expose the API port
EXPOSE 8000

# Run the vLLM OpenAI API server
CMD ["python3", "-m", "vllm.entrypoints.openai.api_server"]