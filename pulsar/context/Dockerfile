ARG PULSAR_IMAGE
FROM $PULSAR_IMAGE

ARG UID GID
RUN groupadd -g $GID pulsar
RUN useradd -u $UID -g $GID -s /bin/bash -m -d /home/pulsar pulsar

USER pulsar

VOLUME /pulsar
WORKDIR /pulsar

ENV PATH=/pulsar/.venv/bin:$PATH
ENV VIRTUAL_ENV=/pulsar/.venv
ENV GALAXY_HOME=/remote-galaxy

CMD pulsar-main
