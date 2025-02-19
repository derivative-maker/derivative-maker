FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

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

RUN mkdir -p /var/log/apt-cacher-ng /etc/apt-cacher-ng /etc/supervisor/conf.d

COPY ./apt-cacher-ng.conf /etc/supervisor/conf.d/apt-cacher-ng.conf
COPY acng.conf /etc/apt-cacher-ng/acng.conf

USER builder

RUN git clone https://github.com/whonix/derivative-maker.git /home/builder/derivative-maker

WORKDIR /home/builder/derivative-maker

USER root

CMD ["/usr/bin/supervisord", "-n"]
