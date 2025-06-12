## Copyright (C) 2025 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

FROM debian:bookworm-slim AS baseimage

ENV \
USER=user \
HOME=/home/user

COPY setup.sh /usr/bin/setup.sh

RUN /usr/bin/setup.sh

FROM baseimage

LABEL org.opencontainers.image.authors="adrelanos@whonix.org"
LABEL org.opencontainers.image.description="Containerization of derivative-maker/derivative-maker"
LABEL org.opencontainers.image.title="derivative-maker-docker"
LABEL org.opencontainers.image.source="https://github.com/derivative-maker/derivative-maker"
LABEL org.opencontainers.image.documentation="https://www.kicksecure.com/wiki/Dev/Build_Documentation/VM"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.vendor="ENCRYPTED SUPPORT LLC"

COPY entrypoint.sh /usr/bin
COPY start_build.sh /usr/bin

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/bin/bash"]
