#!/bin/sh
#
# Bootstrap script for setting up FreeBSD as a vagrant .box
#
# Copyright (c) 2013 Alex Williams, Unscramble <license@unscramble.jp>

UNZIP=`which unzip`
TAR=`which tar`

fail_and_exit() {
        echo "Provisioning failed"
        exit 1
}

# Install some dependencies
pkg_add -r gmake -F && \
pkg_add -r python27 -F && \
pkg_add -r bash -F && \
pkg_add -r py27-pip -F && \
pkg_add -r libyaml -F && \
ln -sf /usr/local/bin/python /usr/bin/python && \
pip install --use-mirrors PyYAML Jinja2 || fail_and_exit

cd /root
  # Extract ansible and install it
  $TAR -zxvf v1.3.3.tar.gz || fail_and_exit
  cd ansible-1.3.3
    # Install Ansible
    gmake install && \
    /usr/local/bin/bash hacking/env-setup || fail_and_exit
  cd ..

  # Extract public provisioning scripts
  $UNZIP -o beta-v2.zip || fail_and_exit
  cd jidoteki-os-templates-beta-v2/provisioning/vagrant
    # Run ansible in local mode
    chmod 644 hosts && \
    ansible-playbook vagrant.yml -i hosts || fail_and_exit
  cd /root

  # Cleanup
  rm -rf v1.3.3.tar.gz ansible-1.3.3 beta-v2.zip jidoteki-os-templates-beta-v2 bootstrap_freebsd.sh
cd ..

echo "Provisioning completed successfully"
exit 0
