#!/bin/bash

echo 'install (gitlab-ce) packages'
ip=$(ip addr ls enp0s3 | grep 'inet ' | cut -d: -f2 | awk '{print $2}' | cut -d/ -f1)
sudo curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo os=ubuntu dist=trusty  bash
sudo EXTERNAL_URL="http://$ip" apt-get install gitlab-ce

echo 'setup (gitlab-ce) to run loccaly'
sudo gitlab-ctl reconfigure
sudo gitlab-ctl start

echo 'Disable ufw firewall'
sudo ufw disable

echo "Create a dedicated namespace named gitlab"
kubectl create ns gitlab

echo "Create a ServiceAccount and provide it with the cluster-admin role"
#RBAC, Role-based access control, is an authorization mechanism for managing permissions around Kubernetes resources

kubectl create -f rbac.yml

echo "Infos to add to existing cluster form"

port=`kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}' | cut -d: -f3`
echo "Cluster name: $(k3d cluster list --no-headers | cut -d' ' -f1)"
echo
echo
echo "API URL: https://$ip:$port"
echo
echo "Certificate:"
echo
kubectl get secret $(kubectl get secret --no-headers=true | cut -d' ' -f1) -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
echo
echo
echo "Token:"
echo
#When the service account is created, Kubernetes will create an token, stored as a secret.
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}') | grep token: | tr -s ' ' | cut -d' ' -f2

#you need to allow requests to the local network from web hooks and services.

#Docs : 
        #https://www.youtube.com/watch?v=NdZfUgz3aaI
        #https://www.civo.com/learn/gitlab-kubernetes-win
        #https://piotrminkowski.com/2020/10/19/gitlab-ci-cd-on-kubernetes/
        #https://betterprogramming.pub/using-a-k3s-kubernetes-cluster-for-your-gitlab-project-b0b035c291a9
        #https://docs.gitlab.com/runner/install/kubernetes.html
        #https://www.youtube.com/watch?v=iQbENcbPtDo&t=494s&ab_channel=NadirAbbas
        #https://docs.gitlab.com/runner/install/kubernetes.html
        #https://docs.gitlab.com/ee/ci/quick_start/
        #https://stackoverflow.com/questions/53370840/this-job-is-stuck-because-the-project-doesnt-have-any-runners-online-assigned