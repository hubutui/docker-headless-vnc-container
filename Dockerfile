# syntax = docker/dockerfile:1.2
FROM debian:stable-slim

# Envrionment config
ENV VNC_PW=vncpassword
ENV VNC_RESOLUTION=1280x1024

# set apt repo mirrors
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt update \
    && apt install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    && sed -i 's,http://deb.debian.org,https://mirrors.tuna.tsinghua.edu.cn,g' /etc/apt/sources.list

# install supervisor, novnc, and vncserver
# we don't use Debian's supervisor config
# but rather regenerate and configure it
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt update \
    && apt install -y --no-install-recommends \
    libnss-wrapper \
    net-tools \
    novnc \
    procps \
    supervisor \
    tigervnc-common \
    tigervnc-standalone-server \
    vim \
    wget \
    && echo_supervisord_conf > /etc/supervisor/supervisord.conf \
    && echo '[include]' >> /etc/supervisor/supervisord.conf \
    && echo 'files = /etc/supervisor/conf.d/*.conf' >> /etc/supervisor/supervisord.conf \
    && ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html
COPY vncserver.conf /etc/supervisor/conf.d/vncserver.conf
COPY novnc.conf /etc/supervisor/conf.d/novnc.conf
COPY startvnc.sh /usr/bin/startvnc.sh
# important, we need write permission here to write logs etc
RUN mkdir -p /headless \
    && chmod 777 -R /headless

# install xorg
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt update \
    && apt install -y --no-install-recommends \
    dbus-x11 \
    fonts-noto-cjk \
    x11-xserver-utils \
    xauth \
    xdg-utils

# Install xfce4 desktop environment and related packages
# you may modify to other desktop environment here
# but xfce4 is recommended as it's a lightweight DE.
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal

# install wps
ARG WPS_URL='https://wdl1.cache.wps.cn/wps/download/ep/Linux2019/10161/wps-office_11.1.0.10161_amd64.deb'
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,target=/tmp \
    wget -qO /tmp/wps.deb ${WPS_URL} \
    && apt update \
    && apt install -y --no-install-recommends \
    /tmp/wps.deb

# install stata deps
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt update \
    && apt install -y --no-install-recommends \
    libtinfo5
EXPOSE 5901 6901
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
