#!/bin/sh
#Initial installation for ansible centos8

RHRELEASE=$(cat /etc/redhat-release)
RHEL_EXPECTED='(^CentOS Linux release 8.*$)'
APPSTREAM_REPO_NAME=AppStream
EPEL_REPO_ADDR="https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
EPEL_REPO_NAME=epel
PREREQ_PKGS='dnf-plugins-core python3 python3-pip git'

PIP=$(which pip3 || which pip2 || which pip)

function pline(){
  echo "==============================================================================="

}

# make sure correct os and version or exit
if ! [[ "$RHRELEASE" =~ $RHEL_EXPECTED ]] 
then
  echo ""
  pline
  echo "Wrong operating system or version."
  echo "Expected: ${RHEL_EXPECTED}"
  echo "Found: ${RHRELEASE}"
  echo "Exitting..."
  exit 1
fi

# Check to see if prereqs are installed
echo ""
pline
echo "Checking for prerequisites..."
for p in ${PREREQ_PKGS}
do
  rpm -q $p || pkg_list="$pkg_list $p"
done

# Install prereqs
if [ "echo $pkg_list|tr -d '[:blank:]'" ]
then
  echo ""
  pline
  echo "Installing prequisites: ${pkg_list}"
  sudo dnf --enablerepo ${APPSTREAM_REPO_NAME} install -y $pkg_list
fi

# Check if ansible is already installed
if [ "$(ansible --version)" ]
then
    ansible --version
    echo ""
    echo "Ansible already installed. Nothing else to do.  Exitting..."
    exit 0
# Try to install via pip if not already
elif [ -x ${PIP} ] && [ -z "$(sudo ${PIP} list --format=columns | grep "^ansible ")" ]
then
    #echo "Ansible already installed.  Exitting..." && exit 0
    sudo ${PIP} install ansible
# Try to install ansible via rpm if not already
elif [ "$(rpm -q ansible)" ]
then
    sudo dnf repolist -y |grep -E "^epel.*$" || \
      sudo dnf install -y $EPEL_REPO_ADDR 
    sudo dnf config-manager -y --dump $EPEL_REPO_NAME|grep 'enabled = 1' || \
      sudo dnf config-manager -y --enable $EPEL_REPO_NAME
    sudo dnf install -y ansible
fi

# Validate ansible responds or print error and exit
pline
echo "Verifying installation...."
ansible --version || \
    ( echo "Something didn't work right, review output and try again..." && \
      exit 1 )

# If you got this far, you should be good, all done, and exit
echo "Installation complete"
exit 0
