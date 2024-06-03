FROM docker.io/library/alpine:3.20.0 as gvisor-tap-vsock
WORKDIR /app/bin
RUN wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.7.3/gvproxy-windows.exe && \
    wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.7.3/gvforwarder && \
    chmod +x ./gvproxy-windows.exe ./gvforwarder
RUN find . -type f -exec sha256sum {} \;

FROM docker.io/library/fedora:37
RUN dnf upgrade -y && \
    dnf install -y iproute iptables-legacy iputils bind-utils wget && \
    dnf clean all
WORKDIR /app
COPY --from=gvisor-tap-vsock /app/bin/gvforwarder ./wsl-gvforwarder
COPY --from=gvisor-tap-vsock /app/bin/gvproxy-windows.exe ./wsl-gvproxy.exe
COPY ./wsl-vpnkit ./wsl-vpnkit.service ./
COPY ./distro/wsl.conf /etc/wsl.conf
RUN ln -s /app/wsl-vpnkit /usr/bin/
