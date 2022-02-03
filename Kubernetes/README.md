# Kubernetes


## Docs links :


[AWS k8s Cluster](https://github.com/akhilrajmailbox/Kubernetes/tree/master/aws-eks)

[GCP k8s Cluster](https://github.com/akhilrajmailbox/Kubernetes/tree/master/gcp-gke)

[K8s production](https://github.com/akhilrajmailbox/Kubernetes/blob/master/kubernetes-production.pdf)

[YAML template](https://github.com/akhilrajmailbox/Kubernetes/tree/master/yaml-template)

[K8s Dashboard](https://github.com/akhilrajmailbox/Kubernetes/tree/master/dashboard)


## K8s Installation in ubuntu 16.04


### prerequisite

1. must run as root user

2. must have docker version compatible with kubernet version

3. copy id_rsa.pub to authorized_keys under /root/.ssh for installation purpose

4. web ui : <<ip-address>>:8080/ui


#### dependencies installation

```
apt-get update && apt-get -y upgrade
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install -y python-software-properties software-properties-common
add-apt-repository -y ppa:webupd8team/java 
apt-get -y update 
apt-get install -y nano wget unzip locate oracle-java8-installer 
update-java-alternatives --set java-8-oracle
apt-get install oracle-java8-set-default && java -version
java -version
nano /etc/profile
apt-get purge docker-ce
rm -rf /var/lib/docker
apt-get purge docker-compose
apt-get update && apt-get install -y apt-transport-https
apt-get install -y docker.io
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl 
ls
sudo mv ./kubectl /usr/local/bin/kubectl 
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
 deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
```


#### kubernetes installation

```
apt-get update
apt-get install -y kubelet kubeadm
kubeadm init
export kubever=$(kubectl version | base64 | tr -d '\n')
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
kubectl get pods --all-namespaces
kubectl get nodes
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get nodes
docker ps
sync && echo 3 > /proc/sys/vm/drop_caches 
kubectl get nodes
kubectl get deployment 
kubectl get rc
kubectl get services
kubectl get --help
```

#### dashboard installation

[apache2-ldap Dashboard](https://github.com/akhilrajmailbox/Kubernetes/tree/master/dashboard/dashboard-apache2-ldap)

[haproxy-basic-auth Dashboard](https://github.com/akhilrajmailbox/Kubernetes/tree/master/dashboard/dashboard-haproxy)

```
nano dashboard.yaml
kubectl create -f dashboard.yaml 
kubectl delete deployment kubernetes-dashboard --namespace=kube-system
kubectl delete prod kubernetes-dashboard --namespace=kube-system
kubectl delete service kubernetes-dashboard --namespace=kube-system
kubectl get pods --all-namespaces
kubectl get services -a -o wide --all-namespaces
kubectl get pods -a -o wide --all-namespaces
kubectl get rc -a -o wide --all-namespaces
kubectl get --help
```



*********************************************************************************
links ::
*********************************************************************************

### basics of K8s

[basics](https://www.digitalocean.com/community/tutorials/an-introduction-to-kubernetes)

[installation](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)

[reference and exporting kubernet home](https://www.weave.works/docs/tutorials/core/part-1-setup-troubleshooting/)

[dashboard](https://kubernetes-v1-4.github.io/docs/user-guide/ui/)

[pods and service](https://docs.openshift.com/enterprise/3.0/architecture/core_concepts/pods_and_services.html)

### you may know before proceeding

[yaml and json file creation 1](https://kubernetes-v1-4.github.io/docs/user-guide/pods/multi-container/)

[yaml and json file creation 2](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/)

[memoru limit](https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/)

[cpu limit](https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/)

[volume options](https://kubernetes.io/docs/concepts/storage/volumes/)


### rolling-update

[link 1](https://tachingchen.com/blog/kubernetes-rolling-update-with-deployment/)

[link 2](https://stackoverflow.com/questions/38251325/kubernetes-deployment-not-doing-rolling-update)

### deployment-strategies

[link 1](https://container-solutions.com/kubernetes-deployment-strategies/)

[link 2](https://www.cncf.io/wp-content/uploads/2018/03/CNCF-Presentation-Template-K8s-Deployment.pdf)

[link 3](https://medium.com/@codefresh/continuous-deployment-strategies-with-kubernetes-c02323789a28)

[link 4](https://kubernetes.io/blog/2018/04/30/zero-downtime-deployment-kubernetes-jenkins/)



[error-solution (incompatibility of versions of docker and kubernets)](http://stackoverflow.com/questions/39005388/fail-to-run-docker-on-kubernetes)



