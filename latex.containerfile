ARG FEDORA_VERSION=38

FROM gabrieleara/toolbox:base-${FEDORA_VERSION}

RUN dnf install -y \
    texlive-scheme-full \
    && dnf clean all \
    && rm -rf /var/cache/yum
