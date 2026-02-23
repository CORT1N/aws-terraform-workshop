FROM alpine:3.23.3

RUN apk add --no-cache \
    aws-cli \
    curl \
    git \
    openssh-client \
    opentofu \
    && adduser -D vscode

USER vscode