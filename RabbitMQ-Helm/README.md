# RabbitMQ Server

RabbitMQ Deployment on K8s

## TL;DR;

```
kubectl create ns rabbitmq
helm repo add ar-rabbitmq https://akhilrajmailbox.github.io/RabbitMQ-Helm/charts
helm install rabbitmq ar-rabbitmq/rabbitmq -n rabbitmq
```

The command deploys the RabbitMQ on the Kubernetes cluster in the default configuration. The [Configuration](#configuration) section lists the parameters that can be configured during installation.

### Custom parameters

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```
helm install rabbitmq ar-rabbitmq/rabbitmq -n rabbitmq --set service.port=5672
```

Alternatively, a YAML file can be provided while installing the chart. This file specifies values to override those provided in the default `values.yaml`. For example,

```
helm install rabbitmq ar-rabbitmq/rabbitmq -n rabbitmq -f my-values.yaml
```

## Updating the chart

To update the chart run:

```
helm upgrade rabbitmq ar-rabbitmq/rabbitmq -n rabbitmq -f my-values.yaml
```

## RabbitMQ Details

```
RABBITMQ_DEFAULT_USER  =  kubectl -n rabbitmq get secret rabbitmq-secret -o jsonpath="{.data.RABBITMQ_DEFAULT_USER}"  | base64 -d
RABBITMQ_DEFAULT_PASS = kubectl -n rabbitmq get secret rabbitmq-secret -o jsonpath="{.data.RABBITMQ_DEFAULT_PASS}"  | base64 -d
SERVICE_IP = kubectl get svc --namespace rabbitmq rabbitmq -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
```


## Uninstalling the Chart

To uninstall/delete the `rabbitmq` deployment:

The command removes all the Kubernetes components associated with the chart and deletes the release.

```
helm uninstall rabbitmq -n rabbitmq
```

## Configure the tls for the rabbitmq server

**Note :** *use the `federation.sh` script to create the certificates under `upstream` and `downstream` folder*

*`upstream` : cacerts, server key and certs for the server machine / upstream server*

*`downstream` : cacerts, client key and certs for the client machine / downstream server*

```
./federation.sh -o ca
./federation.sh -o upstream
./federation.sh -o downstream
kubectl -n rabbitmq create secret generic rabbitmq-cert --from-file=./upstream
```

## Configuration

The following table lists the configurable parameters of the Hyperledger Fabric Orderer chart and default values.

| Parameter                          | Description                                       | Default                                                   |
| ---------------------------------- | ------------------------------------------------- | --------------------------------------------------------- |
| `cluster.enabled`                  | cluster configuration                             | `false`                                                   |
| `cluster.replicaCount`             | number of node if cluster enabled                 | `3`                                                       |
| `rabbitmq.username`                | username                                          | `rabbitmq`                                                |
| `rabbitmq.password`                | password                                          | `MySecurePass`                                            |
| `rabbitmq.erlangCookie`            | erlang cookies                                    | `erlang-cookie=c-is-for-cookie-thats-good-enough-for-me`  |
| `priorityClassName`                | Pod Priority and Preemption                       | `-`                                                       |
| `image.repository`                 | docker repository                                 | `rabbitmq`                                                |
| `image.tag`                        | image tag                                         | `3.8.0-management`                                        |
| `image.pullPolicy`                 | Image pull policy                                 | `Always`                                                  |
| `tls.enabled`                      | tls configuration for rabbitmq                    | `false`                                                   |
| `tls.existingSecret`               | secrets created before the deployment             | `rabbitmq-cert`                                           |
| `service.port`                     | TCP port                                          | `5672`                                                    |
| `service.tlsPort`                  | TCP tls port                                      | `5671`                                                    |
| `service.managementPort`           | TCP management port                               | `15672`                                                   |
| `service.tlsmanagementPort`        | TCP management ssl port                           | `15671`                                                   |
| `service.type`                     | K8S service type exposing ports, e.g. `ClusterIP` | `LoadBalancer`                                            |
| `persistence.enabled`              | persistence volume configuration                  | `true`                                                    |
| `persistence.name`                 | pvc name                                          | `rabbitmq-pvc`                                            |
| `persistence.accessMode`           | Use volume configuration ex:  ReadOnly            | `ReadWriteOnce`                                           |
| `persistence.size`                 | Size of data volume (adjust for production!)      | `10Gi`                                                    |
| `persistence.storageClass`         | Storage class of backing pvc                      | `default`                                                 |
| `podDisruptionBudget.enabled`      | enable or disable podDisruptionBudget             | `false`                                                   |
| `podDisruptionBudget.name`         | podDisruptionBudget name                          | `rabbitmq-pdb`                                            |
| `podDisruptionBudget.minAvailable` | Min Available pod need to up                      | `1`                                                       |
| `podDisruptionBudget.maxUnavailable` | Max Unvailable pod can be to down               | `-`                                                       |
| `networkPolicy.enabled`            | enable or diable networkPolicy                    | `rabbitmq-pdb`                                            |
| `networkPolicy.allowExternal`      | allow external connection (if networkPolicy enabled)| `1`                                                     |
| `networkPolicy.additionalRules`    | extra networkPolicy rules                         | `{}`                                                      |
| `resources`                        | CPU/Memory resource requests/limits              | `{}`                                                       |
| `affinityenabled`                  | enable or disable Affinity                       | `false`                                                    |
| `affinity`                         | Affinity settings for pod assignment             | `{}`                                                       |
| `nodeSelector`                     | Node labels for pod assignment                   | `{}`                                                       |
| `tolerations`                      | Toleration labels for pod assignment             | `[]`                                                       |




## RabbitMQ - Federation Plugin Configuration

**Note :**

* vhost and user can be different
* exchange and queue need to be same in both upstream and downstream server


### Upstream Server & Downstream Server

#### add one rabbitmq user
```
rabbitmqctl add_user {USER_NAME} {SECURE_PASS}
rabbitmqctl set_user_tags {USER_NAME} management
```

#### create one Virtual Host and grant permission to the user we created previously
```
rabbitmqctl add_vhost {VIRTUAL_HOST}
rabbitmqctl set_permissions -p {VIRTUAL_HOST} {USER_NAME} ".*" ".*" ".*"
rabbitmqctl set_permissions -p {VIRTUAL_HOST} rabbitmq ".*" ".*" ".*" # in here `rabbitmq` is default admin user
```

#### create exchane and queue and do binding
```
rabbitmqadmin -s -H localhost -P 15671 -u {USER_NAME} -p {SECURE_PASS} -V {VIRTUAL_HOST} declare exchange name={EX_NAME} type={EX_TYPE} -k
rabbitmqadmin -s -H localhost -P 15671 -u {USER_NAME} -p {SECURE_PASS} -V {VIRTUAL_HOST} declare queue name={QUEUE_NAME} -k
rabbitmqadmin -s -H localhost -P 15671 -u {USER_NAME} -p {SECURE_PASS} -V {VIRTUAL_HOST} declare binding source={EX_NAME} destination={QUEUE_NAME} -k
```


### Downstream Server

#### create federation-upstream
```
rabbitmqctl set_parameter federation-upstream {FEDERATION_NAME} '{"uri":"amqps://{USER_NAME}:{SECURE_PASS}@${RABBITMQ_HOST}:5671?cacertfile=/downstream/cacert.pem&certfile=/downstream/cert.pem&keyfile=/downstream/key.pem&verify=verify_peer&server_name_indication={RABBITMQ_HOST}","expires":3600000}' -p {VIRTUAL_HOST} 
```

#### create policy
```
rabbitmqctl set_policy federation-policy ".*{FEDERATION_NAME}.*" '{"federation-upstream-set":"all"}' --priority 0 --apply-to exchanges -p {VIRTUAL_HOST}
```


### Example configuration

### Upstream Server & Downstream Server
```
rabbitmqctl add_user test_user TestUserPass
rabbitmqctl set_user_tags test_user management
rabbitmqctl add_vhost testvhost
rabbitmqctl set_permissions -p testvhost test_user ".*" ".*" ".*"
rabbitmqctl set_permissions -p testvhost rabbitmq ".*" ".*" ".*"
rabbitmqadmin -s -H localhost -P 15671 -u test_user -p TestUserPass -V testvhost declare exchange name=test_ex type=fanout -k
rabbitmqadmin -s -H localhost -P 15671 -u test_user -p TestUserPass -V testvhost declare queue name=test_queue -k
rabbitmqadmin -s -H localhost -P 15671 -u test_user -p TestUserPass -V testvhost declare binding source=test_ex destination=test_queue -k
```

### Downstream Server
```
rabbitmqctl set_parameter federation-upstream test_fed_name '{"uri":"amqps://test_user:TestUserPass@upstream:5671/testvhost?cacertfile=/downstream/ca_certificate.pem&certfile=/downstream/client_certificate.pem&keyfile=/downstream/private_key.pem&verify=verify_peer&server_name_indication=upstream","expires":3600000}' -p testvhost 

rabbitmqctl set_policy federation-policy ".*test_ex.*" '{"federation-upstream-set":"all"}' --priority 0 --apply-to exchanges -p testvhost 
```


[federation](https://www.rabbitmq.com/federation.html)

[reference](https://github.com/rnurgaliyev/rabbitmq-fed-tls)

[rabbitmq-ssl](https://www.rabbitmq.com/ssl.html)