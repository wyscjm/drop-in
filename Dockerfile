FROM bloodstar/vim

MAINTAINER andy <andycrusoe@gmail.com>

USER root

RUN mkdir -p /etc/ssh/
COPY sshd_config /etc/ssh/sshd_config
COPY init-vim.sh /tmp/init-vim.sh
COPY tmux.conf $HOME/.tmux.conf

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
    $HOME/.tmux/tmux-yank 

RUN python -m venv venv \
    && source venv/bin/activate \
    && venv/bin/pip install pip -U \
    && venv/bin/pip install powerline-status \
    && echo "set shell=/bin/bash" \
    >> $HOME/.vimrc~ \
    && sh /tmp/init-vim.sh

RUN python -m venv $HOME/venv \
    && source $HOME/venv/bin/activate \
    && $HOME/venv/bin/pip install pip -U \
    && $HOME/venv/bin/pip install powerline-status \
    && echo "set shell=/bin/bash" >> $HOME/.vimrc~ \
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
