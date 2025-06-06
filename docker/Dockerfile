FROM debian:bookworm-slim AS baseimage

ENV USER=user \
HOME=/home/user

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y dbus dbus-user-session \
	ca-certificates git time curl lsb-release fakeroot dpkg-dev fasttrack-archive-keyring safe-rm adduser sudo apt-cacher-ng && \
	### user account ###
	adduser --quiet --disabled-password --home ${HOME} --gecos "${USER},,,," ${USER} && \
	echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/passwordless_sudo && \
	chmod 440 /etc/sudoers.d/passwordless_sudo && \
	### clean up ###
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/*

FROM baseimage

LABEL org.opencontainers.image.authors="adrelanos@whonix.org"
LABEL org.opencontainers.image.description="Containerization of Whonix/derivative-maker"
LABEL org.opencontainers.image.title="derivative-maker-docker"
LABEL org.opencontainers.image.source="https://github.com/derivative-maker/derivative-maker"
LABEL org.opencontainers.image.documentation="https://www.kicksecure.com/wiki/Dev/Build_Documentation/VM"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.vendor="ENCRYPTED SUPPORT LLC"

COPY entrypoint.sh /usr/bin
COPY start_build.sh /usr/bin

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/bin/bash"]
