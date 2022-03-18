#!/bin/bash

# Install net-tools to use commands like ifconfig
echo "Install net-tools to use commands like ifconfig"
sudo apt install net-tools -y

# Add k alias to all users
echo "Add k alias to all users"
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
source /etc/profile.d/00-aliases.sh

#### Install Docker follow official doc ####
### https://docs.docker.com/engine/install/ubuntu/
  
# Uninstall old versions if existe
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update apt package and install packages to allow apt use repository over HTTPS:
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y
  
# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
# Use the following command to set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Install K3D
echo "Install K3D"
sudo wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Install Kubectl binary with curl on Linux
### https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

echo "Install Kubectl"
# Download latest release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Create K3d cluster without traefik and setup Argo CD following this docs
### https://k3d.io/v5.3.0/usage/exposing_services/
### https://argo-cd.readthedocs.io/en/stable/getting_started/
### https://en.sokube.ch/post/gitops-on-a-laptop-with-k3d-and-argocd-1

echo "Create K3d cluster"
k3d cluster create mycluster -p 8080:80@loadbalancer -p 8888:30080@loadbalancer --agents 2 --k3s-arg "--disable=traefik@server:0"

echo "Create argocd and dev namespaces"
kubectl create namespace argocd
kubectl create namespace dev

echo "Setup Argo CD"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting Argo CD Setup"
params="-n argocd -l app.kubernetes.io/name=argocd-server --timeout=10m"
kubectl wait --for=condition=available deployment $params
kubectl wait --for=condition=ready pod $params

echo "Config Access to Argo CD Server"
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "Waiting Argo CD Config"
params="-n argocd -l app.kubernetes.io/name=argocd-server --timeout=10m"
kubectl wait --for=condition=available deployment $params
kubectl wait --for=condition=ready pod $params

# change password using https://bcrypt-generator.com/ // pass: Ayoub1337
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {
    "admin.password": "$2a$12$/YEGLr.ZJwlg5oQnXTw5YeeHqnrtHLv2KMiIPtL5K0LRyZwDdApJ2",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
}}'

echo "Clone Argo CD manifest conf"
sudo git clone https://github.com/aerragha/aerragha-config.git ~/p3
sudo kubectl apply -f ~/p3/argocd_manifest/manifest.yaml -n argocd