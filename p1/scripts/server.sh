#!/bin/sh

echo "Executing server.sh with arg $1"

# Install net-tools to use the ifconfig command
yum install net-tools -y

# Install K3S with the server ip
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --bind-address=$1 --node-ip=$1 --tls-san $(hostname) --advertise-address=$1" sh -

# Copy the master node token to scripts folder
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/scripts/

# add alias for kubectl command
echo "alias k='kubectl'" > /etc/profile.d/aliases.sh