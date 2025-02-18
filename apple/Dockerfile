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
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder && \
    chmod 440 /etc/sudoers.d/builder

USER builder

RUN git clone https://github.com/derivative-maker/derivative-maker.git /home/builder/derivative-maker

WORKDIR /home/builder/derivative-maker

CMD ["/bin/bash", "-c", "/home/builder/derivative-maker/derivative-maker --flavor whonix-gateway-xfce --target virtualbox --arch arm64 --debug"]

