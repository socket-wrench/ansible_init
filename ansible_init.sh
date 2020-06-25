#!/bin/sh
#Initial installation for ansible centos8

RHRELEASE=$(cat /etc/redhat-release)
APPSTREAM_REPO_NAME=AppStream
EPEL_REPO_ADDR="https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
EPEL_REPO_NAME=epel


if [[ "$RHRELEASE" =~ (^CentOS Linux release 8.*$) ]]
then
  rpm -q dnf-plugins-core || \
    sudo dnf install -y dnf-plugins-core || \
    exit 1
  for p in dnf-plugins-core python3 python3-pip git
  do
    rpm -q $p || pkg_list="$pkg_list $p"
  done
  [ "echo $pkg_list|tr -d '[:blank:]'" ] && \
    sudo dnf --enablerepo ${APPSTREAM_REPO_NAME} install -y $pkg_list
  if [ "$(sudo pip3 list --format=columns | grep "^ansible ")" ]
  then
    #echo "Ansible already installed.  Exitting..." && exit 0
    sudo pip3 install ansible
  elif [ "$(rpm -q ansible)" ]
  then
    sudo dnf repolist -y |grep -E "^epel.*$" || \
      sudo dnf install -y $EPEL_REPO_ADDR 
    sudo dnf config-manager -y --dump $EPEL_REPO_NAME|grep 'enabled = 1' || \
      sudo dnf config-manager -y --enable $EPEL_REPO_NAME
    sudo dnf install -y ansible
  fi
  ansible --version || \
    ( echo "Something didn't work right, review output and try again..." && \
      exit 1 )
  echo "Installation complete"
  exit 0
else
  echo "Unsupported operating system or verison.
  Expecting: CentOS Linux release 8.x.  
  Retrieved: $RHRELEASE"
  exit 1
fi

