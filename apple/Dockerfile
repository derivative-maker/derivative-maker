FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV APPLE_SILICON_BUILDER=true

RUN apt-get update && \
    apt-get install -y \
    sudo \
    git \
    vim \
    curl \
    build-essential \
    lsb-release \
    apt-cacher-ng \
    procps \
    lsof \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder && \
    chmod 440 /etc/sudoers.d/builder

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

USER builder

WORKDIR /home/builder/derivative-maker

RUN git clone https://github.com/whonix/derivative-maker.git /home/builder/derivative-maker


CMD ["/bin/bash", "-c", "/usr/local/bin/entrypoint.sh"]
