FROM bloodstar/vim

MAINTAINER appotry <andycrusoe@gmail.com>

USER root

# User config
ENV UID="1000" \
    UNAME="developer" \
    GID="1000" \
    GNAME="developer" \
    SHELL="/bin/bash" \
    UHOME=/home/developer

RUN mkdir -p /etc/ssh/
COPY sshd_config /etc/ssh/sshd_config
COPY init-vim.sh /tmp/init-vim.sh
COPY tmux.conf $UHOME/.tmux.conf

RUN echo "http://nl.alpinelinux.org/alpine/edge/testing" \
    >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/community" \
    >> /etc/apk/repositories \
    && apk --no-cache add \
    bash \
    curl \
    git \
    htop \
    libseccomp \
    mosh-server \
    openrc \
    openssh \
    tmux \
    py-pip \
    && git clone https://github.com/tmux-plugins/tmux-yank.git \
    $UHOME/.tmux/tmux-yank 

RUN python -m venv venv \
    && source venv/bin/activate \
    && venv/bin/pip install pip -U \
    && venv/bin/pip install powerline-status \
    && echo "set shell=/bin/bash" \
    >> $UHOME/.vimrc~ \
    && sh /tmp/init-vim.sh

RUN python -m venv $UHOME/venv \
    && source $UHOME/venv/bin/activate \
    && $UHOME/venv/bin/pip install pip -U \
    && $UHOME/venv/bin/pip install powerline-status \
    && echo "set shell=/bin/bash" >> $UHOME/.vimrc~ \
    && sh /tmp/init-vim.sh

RUN rc-update add sshd \
    && echo "1" \
    && rc-status \
    && touch /run/openrc/softlevel
    #&& echo "1" \
    #&& /etc/init.d/sshd start > /dev/null 2>&1 \
    #&& /etc/init.d/sshd stop > /dev/null 2>&1

#              ssh   mosh
EXPOSE 80 8080 62222 60001/udp

COPY start.bash /usr/local/bin/start.bash
ENTRYPOINT ["bash", "/usr/local/bin/start.bash"]
