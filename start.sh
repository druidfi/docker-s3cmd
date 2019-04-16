#!/bin/sh

set -e

S3CMD_BIN=/usr/local/bin/s3cmd

if [[ "$1" == 'conf' ]]; then
    cat /root/.s3cfg
    exit 0
fi

: ${ACCESS_KEY:?"ACCESS_KEY env variable is required"}
: ${SECRET_KEY:?"SECRET_KEY env variable is required"}
: ${S3_PATH:?"S3_PATH env variable is required"}

export DATA_PATH=${DATA_PATH:-/data/}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

echo "access_key=$ACCESS_KEY" >> /root/.s3cfg
echo "secret_key=$SECRET_KEY" >> /root/.s3cfg

if [[ "$1" == 'no-cron' ]]; then
    echo "Job started: $(date)"

    exec ${S3CMD_BIN} sync $PARAMS "$DATA_PATH" "$S3_PATH"

    echo "Job finished: $(date)"

elif [[ "$1" == 'get' ]]; then

    echo "Job get started: $(date)"

    umask 0
    exec ${S3CMD_BIN} get -r $PARAMS  "$S3_PATH" "$DATA_PATH"

    echo "Job get finished: $(date)"

elif [[ "$1" == 'delete' ]]; then
    exec ${S3CMD_BIN} del -r "$S3_PATH"
else
    CRON_ENV="PARAMS='$PARAMS'"
    CRON_ENV="$CRON_ENV\nDATA_PATH='$DATA_PATH'"
    CRON_ENV="$CRON_ENV\nS3_PATH='$S3_PATH'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /sync.sh" | crontab -
    crontab -l
    crond -f
fi
