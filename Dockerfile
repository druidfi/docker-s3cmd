FROM python:3.7-alpine3.9

LABEL version="0.1"
LABEL maintainer="Marko Korhonen <marko.korhonen@druid.fi>"

ARG S3CMD_VERSION=2.0.2

COPY s3cfg /root/.s3cfg
COPY start.sh sync.sh /

RUN chmod +x /start.sh && chmod +x /sync.sh && \
    mkdir /data && \
    pip install s3cmd==${S3CMD_VERSION} && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/start.sh"]
CMD [""]
