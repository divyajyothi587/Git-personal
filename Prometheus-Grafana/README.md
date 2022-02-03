# Prometheus Grafana on Kubernetes

## Use Rancher if you need....!

```
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
```

access the ui >> do the basic configuration, credentials, secondary user with limited permission for managing  and configure grafana




## creating admin privileges for the kube-system namespace:

```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller

# kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
# helm init --service-account tiller --upgrade
```

*prometheus and grafana in eks (macos will not work for array [0] use ubuntu helm) ::*

[link 1](https://eksworkshop.com/monitoring/cleanup/)

[link 2](https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html)


## Raw Metrics:

Make sure that your kubernetes cluster giving you the metrics, if not you have to use some other services in order to achieve it...

```
kubectl get --raw /metrics
```

## make sure that helm installed in your system:

```
helm ls
```

## Create namespace and prometheus with persistentVolume:

*Create the namespace*

```
kubectl create namespace prometheus
```

*Create prometheus with persistentVolume, by default it will use 2 GB and 8 GB for each services*

```
helm install stable/prometheus \
    --name prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.enabled=true \
    --set server.persistentVolume.enabled=true \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"
```

## check all pods and services:

```
kubectl get all -n prometheus
```

## test your prometheus from your local system with port forward:

```
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090
```

[check 1](http://127.0.0.1:8080/)

[check 2](http://127.0.0.1:8080/targets)



## Create namespace and grafana with persistentVolume:

*Create the namespace*

```
kubectl create namespace grafana
```


### Install and configure grafana on `grafana` namespace

**NOTE:** If you are configuring grafana on another kubernetes cluster (A dedicated cluster for monitoting the entire development),then you have to configure helm for this new k8s cluster as well, update `grafana-values.yaml` according to your conifguration and also update `securepassword` with your sensitive admin password and also update the `service.--` parts with your cloud provider configuration, this example showing the axure loadbalancer configuration

```
helm install grafana stable/grafana --namespace grafana -f Kubernetes/grafana-values.yaml
kubectl --namespace grafana get services
```

**want more custom configuration ?**

### without ssl configuration:

*Configuring grafana without ssl configuration*

```
helm install stable/grafana \
    --name grafana \
    --namespace grafana \
    --set persistence.enabled=true \
    --set persistence.storageClassName="gp2" \
    --set adminPassword="MyPassAlwaysSecure" \
    --set datasources."datasources\.yaml".apiVersion=1 \
    --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
    --set datasources."datasources\.yaml".datasources[0].type=prometheus \
    --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.prometheus.svc.cluster.local \
    --set datasources."datasources\.yaml".datasources[0].access=proxy \
    --set datasources."datasources\.yaml".datasources[0].isDefault=true \
    --set service.type=LoadBalancer
```

### with ssl configuration:

*Configuring grafana with ssl certificates*

```
helm install stable/grafana \
    --name grafana \
    --namespace grafana \
    --set persistence.enabled=true \
    --set persistence.storageClassName="gp2" \
    --set adminPassword="MyPassAlwaysSecure" \
    --set datasources."datasources\.yaml".apiVersion=1 \
    --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
    --set datasources."datasources\.yaml".datasources[0].type=prometheus \
    --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.prometheus.svc.cluster.local \
    --set datasources."datasources\.yaml".datasources[0].access=proxy \
    --set datasources."datasources\.yaml".datasources[0].isDefault=true \
    --set service.type=LoadBalancer \
    --set service.port=443 \
    --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-backend-protocol"=http \
    --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-extra-security-groups"=sg-25135300356456469 \
    --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-cert"=arn:aws:acm:us-east-   1:5414653165468143:certificate/09c53c254523-5423-5-14251-dcaf7a9e5b \
    --set service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-ports"=https
```

*edit the service manually in order to accept ssl ceertificates*


from >>
```
  ports:
  - name: service
```

to >>
```
  ports:
  - name: https
```


## check all pods and services:

```
kubectl get all -n grafana
```

## to get the loadbalancer url:

```
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$ELB"
```

## to get the password for admin user:

```
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## Configure grafana with custom dashboards:

* Login into Grafana dashboard using credentials supplied during configuration
* You will notice that ‘Install Grafana’ & ‘create your first data source’ are already completed. We will import community 
* created dashboard for this tutorial
* Click ‘+’ button on left panel and select ‘Import’
* Enter 3131 dashboard id under Grafana.com Dashboard & click ‘Load’.
* Leave the defaults, select ‘Prometheus’ as the endpoint under prometheus data sources drop down, click ‘Import’.
* This will show monitoring dashboard for all cluster nodes
* For creating dashboard to monitor all pods, repeat same process as above and enter 3146 for dashboard id


*few dashboard id for kubernetes monitoring*

```
3131
3146
8588
1860
1621
```

**Note** : you can configure custom dashboard by importing the `json` file from [Custom-Dashboard](#https://github.com/akhilrajmailbox/Prometheus-Grafana/tree/master/Custom-Dashboard)

## Enable the alert:

After you deploy the grafana with helm, do the following steps to configure the Email Alerting. The grafana configuration is mounted to a configmap called "grafana" as a file "grafana.ini".

* you can edit it by the following command and update it with the "smtp" configuration.

```
kubectl -n grafana edit configmap grafana
```

* update the following field with your details

```
  grafana.ini: |
    [smtp]
    enabled = true
    host = smtp.gmail.com:465
    user = yourmail@gmail.com
    password = <<YouSecrets>>
    cert_file =
    key_file =
    skip_verify = true
    from_address = noreply@gmail.com
    from_name = Grafana Admin
    ....
    ....
    ....
    ....
    ....
```

* once you edit and save the configmap, then you have to redeploy the grafana, the simple way is just delete the pod.

```
kubectl -n grafana delete pods grafana-34fe34f3gv3-34f3w
```

* Go to grafana dashboard > Alerting > Notification Channel > Add Channel > test the email configuration, if you are getting some error then please check the logs for grafana pods.

**Note : Don't forget to configure [allow less secure apps](https://support.google.com/accounts/answer/6010255)**

[reference video](https://www.youtube.com/watch?v=j8CVsUEH1V4)



## Delete Prometheus and grafana:

```
helm delete prometheus
helm del --purge prometheus
helm delete grafana
helm del --purge grafana
```
