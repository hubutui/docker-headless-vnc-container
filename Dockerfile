# syntax = docker/dockerfile:1.2
FROM debian:stable-slim

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6901

### Envrionment config
ENV HOME=/headless
ENV TERM=xfce4-terminal
ENV STARTUPDIR=/dockerstartup
ENV NO_VNC_HOME=/headless/noVNC
ENV VNC_COL_DEPTH=24
ENV VNC_RESOLUTION=1280x1024
ENV VNC_PW=vncpassword
ENV VNC_VIEW_ONLY=false

### Install xfce
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt update \
    && apt install -y --no-install-recommends \
    ca-certificates \
    dbus-x11 \
    fonts-noto-cjk \
    locales \
    procps \
    python-numpy \
    vim \
    wget \
    x11-xserver-utils \
    xauth \
    xdg-utils \
    xfce4 \
    xfce4-terminal \
    && locale-gen
ENV LANG='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
ARG TIGERVNC_VERSION=1.8.0
ARG NO_VNC_VERSION=1.0.0
ARG WEBSOCKIFY_VERSION=0.6.1
RUN wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-${TIGERVNC_VERSION}.x86_64.tar.gz | tar xz --strip 1 -C / \
    && mkdir -p $NO_VNC_HOME/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/v${NO_VNC_VERSION}.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME \
    && wget -qO- https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify \
    && ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html

### configure startup
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt update \
    && apt install -y \
    gettext \
    libnss-wrapper \
    && echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc
COPY src/common/xfce $HOME
COPY src/common/scripts/vnc_startup.sh $STARTUPDIR/vnc_startup.sh
COPY src/common/scripts/generate_container_user $STARTUPDIR/generate_container_user
# important, we need write permission here to write logs etc
RUN chmod 777 -R $HOME

### install wps
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
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libgtk2.0-0 \
    libpangocairo-1.0-0 \
    libtinfo5
EXPOSE $VNC_PORT $NO_VNC_PORT
CMD ["/dockerstartup/vnc_startup.sh"]
