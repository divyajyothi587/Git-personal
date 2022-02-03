
# Kubernetes Dashboard

In this deployment and configuration, we are using readonly user with help of RBAC to protect our deployment and infra


### Deploy Kubernetes Dashboard
```
kubectl apply -f dashboard.yaml
```

### Get the token for readonoly user
```
export SECRET_NAME=$(kubectl -n kubernetes-dashboard get secrets | grep "dashboard-user" | awk '{print $1}')
kubectl -n kubernetes-dashboard get secrets ${SECRET_NAME} -o jsonpath="{.data.token}" | base64 --decode
```

### Access K8s Dashboard from your local system
```
kubectl proxy
```

After run the `kubectl proxy` command in your local, access the kubernetes dashboard [here](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login)


[reference](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
