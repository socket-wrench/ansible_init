#!/bin/sh
#Initial installation for ansible centos8

RHRELEASE=$(cat /etc/redhat-release)
RHEL_EXPECTED='(^CentOS Linux release 8.*$)'
APPSTREAM_REPO_NAME=AppStream
EPEL_REPO_ADDR="https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
EPEL_REPO_NAME=epel
PREREQ_PKGS='dnf-plugins-core python36 python3-pip git'


# Define function to print line break
function pline(){
  echo ""
  echo "==============================================================================="
}

# Check if ansible is already installed
if [ "$(ansible --version)" ]
then
  pline
  ansible --version
  pline
  echo "Ansible already installed. Nothing else to do.  Exitting..."
  echo ""
  exit 0
fi

if ! [[ "$RHRELEASE" =~ $RHEL_EXPECTED ]] 
then
  pline
  echo "Wrong operating system or version."
  echo "Expected: ${RHEL_EXPECTED}"
  echo "Found: ${RHRELEASE}"
  echo "Exitting..."
  echo ""
  exit 1
fi

# Check for to make sure dnf is installed
DNF=$(which dnf) || \
  ( pline && \
    echo "No executable found for dnf.  Check your path." && \
    exit 1
  )

# Check to see if prereqs are installed
pline
echo "Checking for prerequisites..."
for p in ${PREREQ_PKGS}
do
  rpm -q $p || pkg_list="$pkg_list $p"
done

# Install prereqs
if [ "${pkg_list// }" ] 
then
  pline
  echo "Installing prequisites: ${pkg_list}"
  sudo dnf --enablerepo ${APPSTREAM_REPO_NAME} install -y $pkg_list
else
  pline
  echo "All prerequisites in place.  Moving on."
fi

# Set path for pip, trying for latest
PIP=$(which pip3 || which pip2 || which pip)

# Try to install via pip if not already
if [ -x ${PIP} ] && [ -z "$(sudo ${PIP} list --format=columns | grep "^ansible ")" ]
then
  pline
  echo "Attempting to install using pip: ${PIP}"
  sudo ${PIP} install ansible
# Try to install ansible via rpm if not already
elif [ "$(rpm -q ansible)" ]
then
  pline
  echo "Attempting to install using dnf."
  sudo dnf repolist -y |grep -E "^epel.*$" || \
    sudo dnf install -y $EPEL_REPO_ADDR 
  sudo dnf config-manager -y --dump $EPEL_REPO_NAME|grep 'enabled = 1' || \
    sudo dnf config-manager -y --enable $EPEL_REPO_NAME
  sudo dnf install -y ansible
else
  pline
  echo "Could not find a valid way to install ansible using $PIP or $(which dnf)"
  exit 1
fi

# Validate ansible responds or print error and exit
pline
echo "Verifying installation...."
ansible --version || \
  ( echo "Something didn't work right, review output and try again..." && \
    echo "" && \
    exit 1 
  )

# If you got this far, you should be good, all done, and exit
pline
echo "Installation complete"
echo ""
exit 0
