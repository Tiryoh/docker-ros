FROM ubuntu:focal-20210609 AS builder
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y --no-install-recommends gcc libc-dev
RUN curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c
RUN gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec
RUN chown root:root /usr/local/bin/su-exec
RUN chmod 0755 /usr/local/bin/su-exec

FROM ubuntu:focal-20210609
LABEL maintainer="Daisuke Sato <tiryoh@gmail.com>"

COPY --from=builder /usr/local/bin/su-exec /sbin/
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends keyboard-configuration language-pack-en && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends wget curl git build-essential ca-certificates tzdata tmux gnupg2 \
        vim sudo lsb-release locales bash-completion zsh iproute2 iputils-ping net-tools dnsutils terminator && \
    rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -k https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends ros-noetic-desktop-full python3-rosdep &&\
    apt-get install -y --no-install-recommends python3-rosinstall python3-rosinstall-generator python3-wstool python3-catkin-tools python3-osrf-pycommon python3-vcstool &&\
    apt-get install -y --no-install-recommends ros-noetic-teleop-twist-keyboard &&\
    rm -rf /var/lib/apt/lists/*
RUN rosdep init && rosdep update
COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]
