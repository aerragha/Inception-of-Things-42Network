#!/bin/sh

echo "Executing worker.sh with arg $1"

# Install net-tools to use the ifconfig command
sudo yum install net-tools -y

# Install K3S with the server ip
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.42.110:6443 --token-file /vagrant/scripts/node-token --node-ip=$1" sh -

# add alias for kubectl command
echo "alias k='kubectl'" > /etc/profile.d/aliases.sh