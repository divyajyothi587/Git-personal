#!/bin/bash
kubectl delete deployment kubernetes-dashboard --namespace=kube-system
kubectl delete service kubernetes-dashboard --namespace=kube-system

kubectl delete deployment apache2-dashboard --namespace=kube-system
kubectl delete service apache2-dashboard --namespace=kube-system

kubectl delete serviceaccounts kubernetes-dashboard --namespace=kube-system
kubectl delete clusterrolebindings kubernetes-dashboard

