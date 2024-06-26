FROM docker.io/library/alpine:3.20.0 as gvisor-tap-vsock
WORKDIR /app/bin
RUN wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.7.3/gvproxy-windows.exe && \
    wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.7.3/gvforwarder && \
    chmod +x ./gvproxy-windows.exe ./gvforwarder
RUN find . -type f -exec sha256sum {} \;

FROM docker.io/library/alpine:3.20.0
RUN apk update && \
    apk upgrade && \
    apk add iproute2 iptables && \
    apk list --installed && \
    rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=gvisor-tap-vsock /app/bin/gvforwarder ./wsl-gvforwarder
COPY --from=gvisor-tap-vsock /app/bin/gvproxy-windows.exe ./wsl-gvproxy.exe
COPY ./wsl-vpnkit ./wsl-vpnkit.service ./service-start.sh ./
COPY ./distro/wsl.conf /etc/wsl.conf
ARG REF=https://example.com/
ARG VERSION=v0.0.0
RUN find ./ -type f -exec sha256sum {} \; && \
    ln -s /app/wsl-vpnkit /usr/bin/ && \
    echo "$REF" > ./ref && \
    echo "$VERSION" > ./version
