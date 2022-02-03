# EKS in AWS

[workernode creation](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html)


## VPC and subnet

[vpn subnet calculation](http://www.vlsm-calc.net/)


### VPC subnet creation steps

```
vpc
Internet GW >> attach igw to vpc
subnet (4)
Nat GW
route table  
# public
>> add route 
1) add two public
>> subnet association
1) 0.0.0.0/0 > igw
```

### see the diagram:

[VPC Subnet png 1](https://github.com/akhilrajmailbox/Kubernetes/blob/master/aws-eks/HA-Subnet.png) 

[VPC Subnet png 2](https://github.com/akhilrajmailbox/Kubernetes/blob/master/aws-eks/vpc_subnet.png)


## ingress-controller

[link 1](https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/)
[link 2](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/blob/master/docs/guide/ingress/annotation.md)
