FROM debian:bookworm-slim AS baseimage

ENV USER=user \
HOME=/home/user

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y dbus dbus-user-session \
	git time curl lsb-release fakeroot dpkg-dev fasttrack-archive-keyring safe-rm adduser apt-cacher-ng && \
	### user account ###
	adduser --quiet --disabled-password --home ${HOME} --gecos '${USER},,,,' ${USER} && \
	echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/passwordless_sudo && \
	chmod 440 /etc/sudoers.d/passwordless_sudo && \
	### clean up ###
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/*

FROM baseimage

LABEL maintainer="derivative-maker"
LABEL org.label-schema.description="Containerization of Whonix/derivative-maker"
LABEL org.label-schema.name="derivative-docker"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-url="https://github.com/derivative-maker/derivative-maker"

COPY entrypoint.sh start_build.sh /usr/bin

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/bin/bash", "-c", "/usr/bin/su ${USER} --command '/usr/bin/start_build.sh'"]
