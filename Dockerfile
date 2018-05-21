FROM huggla/alpine

USER root

# Build-only variables
ENV APP_HOME="/opt/backup" \
    CONFD_VERSION="0.14.0" \
    CONFD_HOME="/opt/confd"

COPY ./backup /${APP_HOME}
COPY ./etc /etc
COPY ./confd ${CONFD_HOME}/etc/conf.d
COPY ./templates /opt/confd/etc/templates

RUN apk update \
 && apk add --no-cache python2 py-pip bash tar curl docker duplicity lftp ncftp py-paramiko py-gobject py-boto py-lockfile ca-certificates librsync py-cryptography py-cffi \
 && pip install --upgrade pip \
 && pip install -r "${APP_HOME}/requirements.txt" \
 && curl -sL https://github.com/michaloo/go-cron/releases/download/v0.0.2/go-cron.tar.gz | tar -x -C /usr/local/bin \
 && mkdir -p "${CONFD_HOME}/etc/conf.d" "${CONFD_HOME}/etc/templates" "${CONFD_HOME}/log" "${CONFD_HOME}/bin" \
 && curl -Lo "${CONFD_HOME}/bin/confd" "https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" \
 && chmod +x "${CONFD_HOME}/bin/confd" \
 && mkdir -p /var/log/backup

ENV VAR_CONFD_PREFIX_KEY="/backup" \
    VAR_CONFD_BACKEND="env" \
    VAR_CONFD_INTERVAL="60" \
    VAR_CONFD_NODES="" \
    VAR_S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    VAR_APP_DATA="/backup" \
    VAR_LINUX_USER="backup" \
    VAR_FINAL_COMMAND="python /opt/backup/backup.py"

USER starter
