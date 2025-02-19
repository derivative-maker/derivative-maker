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

USER builder

RUN git clone https://github.com/whonix/derivative-maker.git /home/builder/derivative-maker

WORKDIR /home/builder/derivative-maker

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

USER root

RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/bin/bash", "-c", "/usr/local/bin/entrypoint.sh"]
