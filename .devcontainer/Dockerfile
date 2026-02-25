FROM alpine:3.23.3

RUN apk add --no-cache \
    aws-cli \
    curl \
    kubectl \
    git \
    openssh-client \
    opentofu \
    && adduser -D vscode

USER vscode