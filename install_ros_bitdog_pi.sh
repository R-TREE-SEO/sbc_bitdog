#!/bin/bash
# Apache License 2.0
# Copyright (c) 2017, ROBOTIS CO., LTD.

echo ""
echo "[Note] Target OS version  >>> Ubuntu for the Raspberry Pi"
echo "[Note] Target ROS version >>> ROS Noetic Ninjemys"
echo "[Note] Catkin workspace   >>> $HOME/catkin_ws"
echo ""
echo "PRESS [ENTER] TO CONTINUE THE INSTALLATION"
echo "IF YOU WANT TO CANCEL, PRESS [CTRL] + [C]"
read

echo "[Set the target OS, ROS version and name of catkin workspace]"
name_os_version=${name_os_version:="focal"}
name_ros_version=${name_ros_version:="noetic"}
name_catkin_workspace=${name_catkin_workspace:="catkin_ws"}

echo "[Update the package lists]"
sudo apt update -y

echo "[Install build environment, the chrony, ntpdate and set the ntpdate]"
sudo apt install -y chrony ntpdate curl build-essential git
sudo ntpdate ntp.ubuntu.com

echo "[Add the ROS repository]"
if [ ! -e /etc/apt/sources.list.d/ros-latest.list ]; then
  sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${name_os_version} main\" > /etc/apt/sources.list.d/ros-latest.list"
fi

echo "[Download the ROS keys]"
roskey=`apt-key list | grep "Open Robotics"`
if [ -z "$roskey" ]; then
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
fi

echo "[Check the ROS keys]"
roskey=`apt-key list | grep "Open Robotics"`
if [ -n "$roskey" ]; then
  echo "[ROS key exists in the list]"
else
  echo "[Failed to receive the ROS key, aborts the installation]"
  exit 0
fi

echo "[Update the package lists]"
sudo apt update -y

echo "[Install the ros-base]"
sudo apt install -y ros-$name_ros_version-ros-base

echo "[Environment setup and getting rosinstall]"
source /opt/ros/$name_ros_version/setup.sh

echo "[Install rosdep and Update]"
sudo apt install python3-rosdep

echo "[Initialize rosdep and Update]"
sudo sh -c "rosdep init"
rosdep update

echo "[Setup 2GB Swap Partition]"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sh -c "echo \"/swapfile swap swap defaults 0 0\" >> /etc/fstab"

echo "[Make the catkin workspace and test the catkin_make]"
mkdir -p $HOME/$name_catkin_workspace/src
cd $HOME/$name_catkin_workspace/src
catkin_init_workspace
cd $HOME/$name_catkin_workspace
catkin_make

echo "[Set the ROS evironment]"
sh -c "echo \"alias eb='nano ~/.bashrc'\" >> ~/.bashrc"
sh -c "echo \"alias sb='source ~/.bashrc'\" >> ~/.bashrc"
sh -c "echo \"alias gs='git status'\" >> ~/.bashrc"
sh -c "echo \"alias gp='git pull'\" >> ~/.bashrc"
sh -c "echo \"alias cw='cd ~/$name_catkin_workspace'\" >> ~/.bashrc"
sh -c "echo \"alias cs='cd ~/$name_catkin_workspace/src'\" >> ~/.bashrc"
sh -c "echo \"alias cm='cd ~/$name_catkin_workspace && catkin_make'\" >> ~/.bashrc"

sh -c "echo \"source /opt/ros/$name_ros_version/setup.bash\" >> ~/.bashrc"
sh -c "echo \"source ~/$name_catkin_workspace/devel/setup.bash\" >> ~/.bashrc"

sh -c "echo \"export ROS_MASTER_URI=http://localhost:11311\" >> ~/.bashrc"
sh -c "echo \"export ROS_HOSTNAME=localhost\" >> ~/.bashrc"

echo "[Install_RT]"
apt-get install python3
apt-get install python3-pip
apt install openssh-server -y
pip3 install pyserial
pip3 install opencv-python
cd $HOME/$name_catkin_workspace

source $HOME/.bashrc

echo "[Complete!!!]"
exit 0
