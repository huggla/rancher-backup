FROM huggla/alpine

# Build-only variables
ENV APP_HOME="/opt/backup" \
    CONFD_VERSION="0.14.0" \
    CONFD_HOME="/opt/confd"

COPY ./backup/requirements.txt /${APP_HOME}/
COPY ./etc /etc
COPY ./templates /opt/confd/etc/templates
COPY ./backup/src/ /${APP_HOME}/
COPY ./backup/config /${APP_HOME}/config

RUN apk update \
 && apk add --no-cache python2 py-pip bash tar curl docker duplicity lftp ncftp py-paramiko py-gobject py-boto py-lockfile ca-certificates librsync py-cryptography py-cffi \
 && pip install --upgrade pip \
 && pip install -r "${APP_HOME}/requirements.txt" \
 && curl -sL https://github.com/michaloo/go-cron/releases/download/v0.0.2/go-cron.tar.gz | tar -x -C /usr/local/bin \
 && mkdir -p "${CONFD_HOME}/etc/conf.d" "${CONFD_HOME}/etc/templates" "${CONFD_HOME}/log" "${CONFD_HOME}/bin" \
 && curl -Lo "${CONFD_HOME}/bin/confd" "https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" \
 && chmod +x "${CONFD_HOME}/bin/confd" \
 && curl -sL https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz | tar -zx -C / \
 && mkdir -p /var/log/backup


&& mkdir -p ${APP_DATA} \
 && adduser -D -h ${APP_HOME} -G docker -s /bin/sh ${USER} \
 && chown -R ${USER} ${APP_HOME} \
 && chown -R ${USER} ${APP_DATA} \
 && chown -R ${USER} /var/log/backup \
 && rm -rf /tmp/* /var/tmp/*

ENV VAR_CONFD_PREFIX_KEY="/backup" \
    VAR_CONFD_BACKEND="env" \
    VAR_CONFD_INTERVAL="60" \
    VAR_CONFD_NODES="" \
    VAR_S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    VAR_APP_DATA="/backup" \
    VAR_LINUX_USER="backup" \
    VAR_FINAL_COMMAND="python /opt/backup/backup.py"

    CONTAINER_NAME="rancher-backup" \
    CONTAINER_AUHTOR="Sebastien LANGOUREAUX <linuxworkgroup@hotmail.com>" \
    CONTAINER_SUPPORT="https://github.com/disaster37/rancher-backup/issues" \
    APP_WEB="https://github.com/disaster37/rancher-backup"


CMD ["/init"]
