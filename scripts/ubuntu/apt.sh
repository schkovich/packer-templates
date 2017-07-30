#!/bin/bash

set -e
set -x

# In Ubuntu 12.04, the contents of /var/lib/apt/lists are corrupt
ubuntu_version=$(lsb_release -r | awk '{ print $2 }')
if [ "$ubuntu_version" == '12.04' ]; then
  sudo rm -rf /var/lib/apt/lists
fi
INSTALL_COMMAND="apt-get -qq -o Dpkg::Options::='--force-confnew' -y install"
PACKAGES="build-essential git software-properties-common ruby ruby-dev"
PUPPET_REPO="http://apt.puppetlabs.com/puppetlabs-release-pc1-%s.deb"
DISTRIB_CODENAME=$(lsb_release --codename --short)
REPO_DEB_URL=$(printf ${PUPPET_REPO} ${DISTRIB_CODENAME})
REPO_DEB_PATH=$(mktemp)

sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo bash -c "${INSTALL_COMMAND} ${PACKAGES}"

wget -q --output-document="${REPO_DEB_PATH}" "${REPO_DEB_URL}"
sudo dpkg -i "${REPO_DEB_PATH}"
rm "${REPO_DEB_PATH}"

sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo bash -c "${INSTALL_COMMAND} puppet-agent"

cd /usr/bin
sudo ln -s /opt/puppetlabs/bin/puppet
sudo ln -s /opt/puppetlabs/bin/hiera
sudo ln -s /opt/puppetlabs/bin/facter
sudo ln -s /opt/puppetlabs/bin/mco
sudo gem install librarian-puppet --no-rdoc --no-ri
sudo gem install deep_merge --no-rdoc --no-ri
