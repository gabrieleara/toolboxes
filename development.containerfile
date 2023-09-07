ARG FEDORA_VERSION=38

FROM gabrieleara/toolbox:base-${FEDORA_VERSION}

RUN dnf install -y \
    autoconf \
    automake \
    binutils \
    bison \
    clang \
    cmake \
    doxygen \
    flex \
    gcc \
    gcc-c++ \
    gdb \
    glibc-devel \
    highlight \
    libtool \
    llvm \
    make \
    patch \
    patchutils \
    perf \
    pkgconf \
    strace \
    valgrind \
    && dnf clean all \
    && rm -rf /var/cache/yum
