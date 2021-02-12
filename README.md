# Docker container images with "headless" VNC session

## How this container work

We need to install these packages in the container:
* [TigerVNC](https://tigervnc.org/) as vncserver
* [libnss-wrapper](https://cwrap.org/nss_wrapper.html) for non-root user to run as expected
* [noVNC](https://github.com/novnc/noVNC) as HTML5 VNC client
* [Xfce](https://www.xfce.org) desktop environment

## Build and run
To build this Docker image, run:

```bash
docker build -t vnc-xfce .
```

To run a container:

```bash
docker run -d -p 5901:5901 -p 6901:6901 --env VNC_PW=vncpassword --env VNC_RESOLUTION=1280x1024 vnc-xfce
```

or if you'd like to run with the same user as host system:

```bash
docker run -d -p 5901:5901 -p 6901:6901 --env VNC_PW=vncpassword --env VNC_RESOLUTION=1280x1024 --user $(id -u):$(id -g) vnc-xfce
```

Now, you could connect to the container with:
* a VNC client using `IP:5901` with password `vncpassword`
* a web browser to `http://IP:6901` or `http://IP:6901/vnc_lite.html`
where IP is your host system IP.