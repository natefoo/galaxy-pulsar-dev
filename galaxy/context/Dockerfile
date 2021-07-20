ARG GALAXY_IMAGE
FROM $GALAXY_IMAGE

ARG UID GID
RUN groupadd -g $GID galaxy
RUN useradd -u $UID -g $GID -s /bin/bash -m -d /home/galaxy galaxy

USER galaxy

VOLUME /galaxy
WORKDIR /galaxy

ENV PATH=/galaxy/.venv/bin:$PATH
ENV VIRTUAL_ENV=/galaxy/.venv
