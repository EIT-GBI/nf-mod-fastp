ARG DEBIAN_VERSION=13-slim
ARG FASTP_VERSION=0.23.4
ARG FASTP_SHA256=4fad6db156e769d46071add8a778a13a5cb5186bc1e1a5f9b1ffd499d84d72b5

# builder #####################################################################

FROM debian:${DEBIAN_VERSION} AS builder

ARG FASTP_VERSION
ARG FASTP_SHA256
ARG FASTP_URL="https://github.com/OpenGene/fastp/archive/refs/tags/v${FASTP_VERSION}.tar.gz"

ENV DEBIAN_FRONTEND=noninteractive

# fastp links against libdeflate and isa-l as well as zlib
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libdeflate-dev \
        libisal-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN curl -fsSL --retry 3 -o "fastp.tar.gz" "${FASTP_URL}" \
    && echo "${FASTP_SHA256}  fastp.tar.gz" | sha256sum -c - \
    && tar -xzf fastp.tar.gz \
    && cd "fastp-${FASTP_VERSION}" \
    && make -j"$(nproc)" \
    && install -Dm755 fastp /opt/fastp/bin/fastp \
    && strip /opt/fastp/bin/fastp || true

# runtime #####################################################################

FROM debian:${DEBIAN_VERSION} AS runtime

ARG DEBIAN_VERSION
ARG FASTP_VERSION

LABEL org.opencontainers.image.title="fastp" \
    org.opencontainers.image.description="fastp on debian:${DEBIAN_VERSION}" \
    org.opencontainers.image.version="${FASTP_VERSION}" \
    org.opencontainers.image.source="https://github.com/OpenGene/fastp" \
    org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/fastp/bin:${PATH} \
    LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libdeflate0 \
        libisal2 \
        procps \
        zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY --from=builder /opt/fastp /opt/fastp

# No ENTRYPOINT: Nextflow invokes the container as `/bin/bash -c ...`, and an
# ENTRYPOINT of ["fastp"] would turn that into `fastp /bin/bash`.
CMD ["fastp", "--version"]
