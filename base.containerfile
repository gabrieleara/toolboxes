ARG FEDORA_VERSION=38

FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION}

RUN curl --output-dir /etc/yum.repos.d/ -O \
    https://copr.fedorainfracloud.org/coprs/returntrip/ripgrep-all/repo/fedora-38/returntrip-ripgrep-all-fedora-38.repo \
    && dnf install -y \
    bat \
    beep \
    colordiff \
    fd-find \
    fish \
    fzf \
    gnuplot \
    htop \
    make \
    ripgrep \
    ripgrep-all \
    the_silver_searcher \
    tmux \
    wl-clipboard \
    && dnf clean all \
    && rm -rf /var/cache/yum
