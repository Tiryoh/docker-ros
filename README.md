# docker-ros

Dockerfiles of ROS to use with osrf/rocker

## Usage

Melodic (without NVIDIA GPU)

```
rocker --x11 --user --network=host --privileged --volume ~/catkin_ws -- tiryoh/ros:melodic
```


Melodic (with NVIDIA GPU)

```
rocker --x11 --nvidia --user --network=host --privileged --volume ~/catkin_ws -- tiryoh/ros:melodic
```
