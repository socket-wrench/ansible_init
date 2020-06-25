#!/bin/sh
#Initial installation for ansible centos8

REPO_ADDR="https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
RHRELEASE=$(cat /etc/redhat-release)

rpm -q ansible && echo "Ansible already installed.  Exitting..." && exit 0

if [[ "$RHRELEASE" =~ (^CentOS Linux release 8.*$) ]]
then
  rpm -q dnf-plugins-core || sudo dnf install -y dnf-plugins-core || exit 1
  sudo dnf repolist -y |grep -E "^epel.*$" || sudo dnf install -y $REPO_ADDR 
  sudo dnf config-manager -y --dump epel|grep 'enabled = 1' || sudo dnf config-manager -y --enable epel
  sudo dnf install -y python3 python3-pip
  sudo pip3 install ansible
  ansible --version
  echo "Installation complete"
  exit 0
else
  echo "Unsupported operating system or verison.
  Expecting: CentOS Linux release 8.x.  
  Retrieved: $RHRELEASE"
  exit 1
fi

