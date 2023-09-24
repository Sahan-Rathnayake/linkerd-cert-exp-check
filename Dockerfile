FROM amd64/alpine:latest

ARG KUBECTL_VERSION=1.24.13

RUN apk add --update --no-cache curl ca-certificates bash git openssl coreutils 

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

RUN apk add --update --no-cache python3 && \
    python3 -m ensurepip && \
    pip3 install --upgrade pip && \
    pip3 install awscli && \
    pip3 cache purge

COPY scripts/cert-exp-check.sh /opt/scripts/cert-exp-check.sh
