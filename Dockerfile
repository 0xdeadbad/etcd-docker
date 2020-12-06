FROM alpine:3.12

ARG ETCD_VERSION=v3.4.14
ARG ARCH=amd64

RUN wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${ARCH}.tar.gz -O - | tar xvz -C /tmp

RUN mv /tmp/etcd-${ETCD_VERSION}-linux-${ARCH}/etcd* /usr/local/bin

RUN rm -rf /tmp/etcd*

RUN mkdir -p /etc/etcd /var/lib/etcd

COPY ./entrypoint.sh /entrypoint.sh

EXPOSE 2379 2380

ENTRYPOINT ["/bin/ash", "-c", "/entrypoint.sh"]
