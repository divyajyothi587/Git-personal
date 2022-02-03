# Hello World App with Go

## Deployment Features

* `helm charts` and `kubectl YAML` deployment
* `multi-stage` builds in dockerfile
* using `alpine` docker image for security and lightweight.
* custom `fast` storageclass which will allow you to increase the disk size any time with help of storageclass varibale : `allowVolumeExpansion: true`
* The hello-world application use `initcontainer` to download the data to `/data` folder
* Using `podAffinity` for increse the performance (read and write to mongodb) 
* Using `podAntiAffinity` for High availability incase if we have cluster
* `readinessProbe` wait till the service up before accepting the request
* `livenessProbe` ensure the service availability
* using `persistentVolumeClaim` for MongoDB and Hello wold Application


**Note The `storageclass` Configuration is not mandatory to run this services, but I conifgured to showcase how we can achieve high throughput / io operation and capability to increase the disk size anytime even in production system**


## Local Deployment (docker-compose deployment)

for Local testing purpose, `docker-compose and docker` can be used.

```
cd Docker-Deployment/
docker-compose up -d
```


### Deployment Option on Kubernetes

* helm
* kubectl

#### Helm-tiller-configuration (configure this only if your helm client version < 3.x.x)

* this is a server level helm configuration and it required for helm version 2.x.x (RBAC)
```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
```


#### Helm Deployment (TL;DR)

```
helm repo add ar-demo https://akhilrajmailbox.github.io/GoLang-K8s-service/docs
helm install ar-demo/hello-world -n hello-world --namespace=demo
```

##### configure with your custom environment values from `custom-values.yaml`
```
helm install ar-demo/hello-world -n hello-world --namespace=demo -f custom-values.yaml
```


## Configuration

The following table lists the configurable parameters of the hell-world chart and default values.

| Parameter                          | Description                                      | Default                                                   |
| ---------------------------------- | ------------------------------------------------ | ---------------------------------------------------------- |
| `replicaCount`                     | number of pods to deploy                         | `1`                                                   |
| `maxSurge`                         | control the rolling update process               | `1`                                                   |
| `maxUnavailable`                   | control the rolling update process               | `1`                                                   |
| `image.repository`                 | `hello-world` image repository                   | `akhilrajmailbox/golang`                                                   |
| `image.tag`                        | `hello-world` image tag                          | `hello-world`                                                   |
| `initContainers.entrypoint`        | `hello-world` init container entrypoint          | [entrypoint](#initContainers-entrypoint)                                                   |
| `env.mongodb`                      | mongodb url                               | `hello-world-mongodb:27017`                                              |
| `mongodb.enabled`                  | configure mongodb                                | `true`                                             |
| `mongodb.replicaSet.enabled`       | mongodb helm charts configuration                                         | `true`                                                     |
| `mongodb.usePassword`              | mongodb helm charts configuration     | `false`                                                    |
| `mongodb.persistence.enabled`      | mongodb helm charts configuration     | `true`                                                    |
| `mongodb.persistence.accessMode`   | mongodb helm charts configuration     | `ReadWriteOnce`                                                    |
| `mongodb.persistence.size`         | mongodb helm charts configuration     | `10Gi`                                                    |
| `mongodb.persistence.storageClass` | mongodb helm charts configuration                     | `default`                                                  |
| `persistence.enabled`              | Use volume as ReadOnly or ReadWrite              | `ReadWriteOnce`                                            |
| `persistence.accessMode`           | Use volume as ReadOnly or ReadWrite              | `ReadWriteOnce`                                            |
| `persistence.annotations`          | Persistent Volume annotations                    | `{}`                                                       |
| `persistence.size`                 | Size of data volume (adjust for production!)     | `10Gi`                                                    |
| `persistence.storageClass`         | Storage class of backing PVC                     | `default`                                                  |
| `resources.requests.cpu`           | CPU/Memory resource requests/limits              | `100m`                                                      |
| `nodeSelector`                     | Node labels for pod assignment                   | `{}`                                                       |
| `tolerations`                      | Toleration labels for pod assignment             | `[]`                                                       |
| `affinity`                         | Affinity settings for pod assignment             | [affinity](#affinity)                                                       |


## Kubernetes Deployment with YAML (kubectl)

* Create Namespaces
```
kubectl apply -f namespace.yaml
```

**Optional Configuration for Storageclass**

*  Configure `fast` storageclass with `allowVolumeExpansion: true` (for an example I choose AWS and Azure as Cloud Providers)

**AWS Cloud**
```
kubectl apply -f storageclass/AWS-storageclass.yaml
```

**Azure Cloud**
```
kubectl apply -f storageclass/Azure-storageclass.yaml
```

**Warning: If you don't need to configure `fast` storageclass, then update your `hello-world-pvc.yaml` and `mongo-pvc.yaml` with `storageClassName: default` instelad of `storageClassName: fast`**

so your `pvc` files will lok like as follows :

```
apiVersion: v1
kind: PersistentVolumeClaim
.....
.....
.....
  storageClassName: default
```

* Create Persistent Volume Claim and Deploy `MongoDB` on namespace `mongo`
```
kubectl apply -f mongo-pvc.yaml
kubectl apply -f mongo-deployment.yaml
kubectl apply -f mongo-service.yaml
```

* Create Persistent Volume Claim and Deploy `Hello-World` App on namespace `hello-world`
```
kubectl apply -f hello-world-pvc.yaml
kubectl apply -f hello-world-deployment.yaml
kubectl apply -f hello-world-service.yaml
```


#### Reference for Default Values for helm charts

##### initContainers-entrypoint

```
apt-get update && apt-get install wget -y && cd /data ; wget https://speed.hetzner.de/100MB.bin
```

##### affinity
* The affinity configured as follows for High availability and better performance

```
affinity:
  podAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 95
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - mongodb
        topologyKey: kubernetes.io/hostname
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchLabels:
            app: hello-world
        topologyKey: kubernetes.io/hostname
      weight: 95
```
