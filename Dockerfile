FROM debian:bullseye-backports

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -t bullseye-backports  -y curl openssl unzip git

COPY deploy.sh /deploy.sh
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
