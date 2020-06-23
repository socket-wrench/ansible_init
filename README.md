# Ansible Init
Installation script for ansible on centos 8

## Prerequisites
  * centos >= 8.0
  * dnf-plugins-core
  * either root access or sudo access to the following commands
    * dnf repolist
    * dnf config-manager
    * dnf install

## Usage

Extract the package and run the shell script *ansible_init.sh*

    # unzip ansible_init.zip
    # cd ansible_init
    # chmod +x ansible_init.sh
    # ./ansible_init.sh
