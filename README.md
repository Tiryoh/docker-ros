# docker-ros

Dockerfiles of ROS to use with osrf/rocker

## Usage (with osrf/rocker)

Noetic (without NVIDIA GPU)

```
rocker --x11 --user --network=host --privileged --volume ~/catkin_ws -- tiryoh/ros:noetic
```


Noetic (with NVIDIA GPU)

```
rocker --x11 --nvidia --user --network=host --privileged --volume ~/catkin_ws -- tiryoh/ros:noetic
```

## Usage (without osrf/rocker)

```
ROS_DISTRO=noetic ./run.sh
```
