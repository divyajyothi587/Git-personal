#!/bin/bash
kubectl create secret docker-registry <<name>> \
   --docker-server=<<server name>> \
   --docker-username=<<user name>> \
   --docker-password=<< password>> \
   --docker-email=<<email address>>
