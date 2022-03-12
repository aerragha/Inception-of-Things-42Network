#!/bin/sh

echo "Executing server.sh with arg $1"

# Install net-tools to use the ifconfig command
yum install net-tools -y

# Install K3S with the server ip
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --bind-address=$1 --node-ip=$1 --tls-san $(hostname) --advertise-address=$1 --flannel-iface=eth1" sh -

# add alias for kubectl command
echo "alias k='kubectl'" > /etc/profile.d/aliases.sh

echo "Setup Web App 1"
/usr/local/bin/kubectl apply -f /vagrant/config/app1.yaml -n kube-system

echo "Setup Web App 2"
/usr/local/bin/kubectl apply -f /vagrant/config/app2.yaml -n kube-system

echo "Setup Web App 3"
/usr/local/bin/kubectl apply -f /vagrant/config/app3.yaml -n kube-system

echo "Create Ingress"
/usr/local/bin/kubectl apply -f /vagrant/config/ingress.yaml -n kube-system
