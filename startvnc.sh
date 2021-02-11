#!/bin/bash
# Set current user in nss_wrapper
USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [ x"$USER_ID" != x"0" ]; then
    export NSS_WRAPPER_PASSWD=/tmp/passwd
    export NSS_WRAPPER_GROUP=/tmp/group
    export HOME=/headless

    cat /etc/passwd > ${NSS_WRAPPER_PASSWD}
    cat /etc/group > ${NSS_WRAPPER_GROUP}
    echo "default:x:${USER_ID}:${GROUP_ID}::${HOME}:/bin/bash" >> ${NSS_WRAPPER_PASSWD}
    echo "default:x:${GROUP_ID}:" >> ${NSS_WRAPPER_GROUP}

    if [ -r /usr/lib/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib/libnss_wrapper.so
    elif [ -r /usr/lib64/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
    else
        echo "no libnss_wrapper.so found!"
        exit 1
    fi
    echo "nss_wrapper location: ${LD_PRELOAD}"
fi

rm -rfv ${HOME}.vnc
mkdir -p ${HOME}/.vnc
echo "${VNC_PW}" | vncpasswd -f > ${HOME}/.vnc/passwd
chmod 600 ${HOME}/.vnc/passwd
echo "x-session-manager" > ${HOME}/.vnc/xstartup
chmod +x ${HOME}/.vnc/xstartup
vncserver -localhost no -fg :1 -geometry ${VNC_RESOLUTION}
