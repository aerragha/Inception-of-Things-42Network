#!/bin/bash

echo 'install Helm'
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

helm repo add gitlab https://charts.gitlab.io

gitlabUrl="http://$(ip addr ls enp0s3 | grep 'inet ' | cut -d: -f2 | awk '{print $2}' | cut -d/ -f1)/"
runnerRegistrationToken="Add your runner tocken"

echo "install gitlab runner using helm chart"

helm install --namespace gitlab gitlab-runner --set gitlabUrl=$gitlabUrl,runnerRegistrationToken=$runnerRegistrationToken -f runner-gitlab.yml  gitlab/gitlab-runner

# helm status --namespace gitlab gitlab-runner to check the status
