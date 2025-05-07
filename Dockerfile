FROM amd64/alpine:latest

RUN apk add --update --no-cache curl ca-certificates bash coreutils aws-cli openssl

WORKDIR /opt/scripts

COPY scripts/cert-exp-check.sh .

CMD [ "/bin/bash", "/opt/scripts/cert-exp-check.sh" ]