#!/usr/bin/env bash
set -e

ROS_DISTRO=${ROS_DISTRO:-noetic}
DOCKER_IMAGE_NAME="tiryoh/ros:${ROS_DISTRO}"
DEFAULT_SHELL=bash
DEFAULT_USER=ubuntu

# ディレクトリへの絶対パスが異なる場合は別の名前でコンテナを立ち上げる（共有PCや異なるROSDistroでの利用を想定）
command -v crc32 >/dev/null || { echo ERROR: crc32 command not found. Try "sudo apt-get update && sudo apt-get install -y libarchive-zip-perl"; exit 1; }
CONTAINER_NAME="ros_${ROS_DISTRO}_$(crc32 <(echo ${WS_ROOT_DIR}))"

# コンテナがすでに起動しているかどうか確認
if docker ps -a | grep -q ${CONTAINER_NAME}; then
        echo Found container: ${CONTAINER_NAME}
        # 引数が何もなければshellをインタラクティブモードで起動する
        if [ "$#" == 0 ]; then
                docker exec -it ${CONTAINER_NAME} ${DEFAULT_SHELL}
        else
                docker exec -it ${CONTAINER_NAME} "$@"
        fi

else
        echo Starting container: ${CONTAINER_NAME}
        # コンテナが起動していなければ、新規に立ち上げる
        docker run --rm -it \
                --privileged \
                --ipc=host \
                --net=host \
                --name ${CONTAINER_NAME} \
                -e CONTAINER_NAME=${CONTAINER_NAME} \
                -e DISPLAY \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v /etc/localtime:/etc/localtime \
                -v ${HOME}/catkin_ws/src:/ws \
                ${DOCKER_IMAGE_NAME} \
                "$@"
fi

