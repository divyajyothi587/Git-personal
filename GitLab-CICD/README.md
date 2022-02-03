# CICD-Labs

This setup have the following feature. The high availability can be achieved by configuing the AWS as follows:

- [ ] High Avaialble setup

- [ ] Kubernetes for container orchestrator

- [ ] CI/CD with GitLab ci


## Take a look

- [ ] [Source Code]()

- [ ] [Docker Image](https://hub.docker.com/r/akhilrajmailbox/demo-data-collector/tags)


`Here we are using micro service architecture and so not using Ansible`


we can choose 2 nodes (t3.medium -- 2 VCPU * 4 GB) in different zone. The main reason why I choose 2 worker Node is for HA Configuration, ie) even one zone goes down completely, our application will serve without any issue because of the second zone.

configure auto scaling group of worker nodes that register with your Amazon EKS cluster if we need HA.

we can configure autoscaler for the kubernetes deployment if we are going with deployment/statefulset etc.. here i am choosing cronjob so that it can download the data in every periodic intervel and can save the computation cost.


## Additional components / plugins would you install on the cluster to manage it better

- [ ] Prometheus and Granada for monitoring.

- [ ] EFK (Elasticsearch, Fluentd and Kibana) for logging.

- [ ] helm for installation of predefined applications as charts (here I am using simple yml file).

- [ ] KMS for securing the sensitive information. (in here I am just using kubernetes configmap to store the data but in production we have to use envolop encryption with AWS KMS)


## Prerequisites

- [ ] Kubernetes Service (EKS)

- [ ] S3 Bucket with Web hosting enabled

- [ ] Docker Registry (Dockerhub / ECR)

- [ ] Local system requirement (aws cli, kubectl, terraform)


## AWS Authetication and configure AWS profile

In this demo, we will use aws cli, kubectl and Terraform to access to your AWS resources. If you already have an AWS profile set up with the necessary permissions, you can skip to the next section. For the sake of simplicity, and to avoid telling Terraform directly, Create IAM user and download its credentials, then run the command:

```shell
aws configure
```

*I am using custom aws profile here, you can also try that, else you can use the default profile*


## Terraform

### Basic configuration before get started

Install terraform to your local machine from [here](https://learn.hashicorp.com/tutorials/terraform/install-cli), It’s a good idea to test your new Terraform installation using the following command: `terraform version`

Here I am pro tips for terraform, instead of storing the state in local or in repo, i am planning to store it under [S3 bucket](https://www.terraform.io/docs/language/settings/backends/s3.html), so lets do it.... I will create two Terraform files:

* `main.tf` which will contain our provider information

* `state.tf` which will include all of our state resources

#### Step 1

* Update `main.tf` with your aws profile and details

* In `state.tf` remove terraform.backend snippet, update the bucket name and dynamodb table name. so the `state.tf` file will having the following entries:

```code
resource "aws_s3_bucket" "terraform_state" {
    bucket = "akhilz-terraform-state"
    acl    = "private"
    # Enable versioning so we can see the full revision history of our
    # state files
    versioning {
        enabled = true
    }
    # Enable server-side encryption by default
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_s3_block" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
    name         = "akhilz-terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}
```

Now we have to create the s3 bucket and its dependencies in AWS by running the following command.

```shell
terraform init
terraform apply -target="aws_s3_bucket.terraform_state" -target="aws_s3_bucket_public_access_block.terraform_state_s3_block" -target="aws_dynamodb_table.terraform_locks"
```

#### Step 2

* In `state.tf` add terraform.backend snippet with the correct name for s3 bucket, dynamodb table, aws profile etc.. and remove rest all entries. also remove `terraform.tfstate` to avoid the deletion of state s3 bucket which we had created just now

```code
rm -rf terraform.tfstate .terraform terraform.tfstate.* .terraform.*
```

```code
terraform {
    backend "s3" {
        bucket         = "akhilz-terraform-state"
        key            = "state/terraform.tfstate"
        region         = "ap-south-1"
        encrypt        = true
        dynamodb_table = "akhilz-terraform-locks"
        shared_credentials_file = "~/.aws/credentials"
        profile = "akhilz-aws"
    }
}
```

* re-run the follwoing command and this will tell terraform to use the s3 bucket as the backned to store the state in future.

```shell
terraform init
```

* The final step here is to run terraform plan to ensure that all of the resources in our code have been properly created and that everything is running correctly.

```shell
terraform plan
```


### Create the Infra using terraform

**Please note that there is some pricing involved with spinning up this cluster. You pay $0.20 per hour for the Amazon EKS control plane**

Now we have to update the configuration and run the terraform command to create our infrastructure. please follow the steps to do that.

* Update `variables.tf` with some other name for s3, ec2-components

* Update `eks_subnet_list` in `variables.tf` with the subnet id of your VPC. (here I am using default VPC from AWS, if we want to create new VPC then we can try with VPC module fo terraform)

* execute the following command to initiate the infra creation within Terraform directory

```shell
terraform plan
terraform apply
```

## Access your Kubernetes cluster

Validate all the kubernetes configuration form your local or remote machine before start deploying from Gitlab ci.

* Configure AWS CLI in local system

```shell
aws configure
```

* Install kubectl

Kubernetes uses a command line utility called kubectl for communicating with the cluster API server.

You must use a kubectl version that is within one minor version difference of your Amazon EKS cluster control plane . For example, a 1.11 kubectl client should work with Kubernetes 1.10, 1.11, and 1.12 clusters...

* create a kubeconfig file for your cluster

```shell
aws eks --region ap-south-1 update-kubeconfig --name eks-cluster
```

* Check to see if your worker node has properly registered:

```shell
kubectl get nodes
```

* We have to create a gitlab service account that we will use to deploy to Kubernetes from GitLab.


```code
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-service-account
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-service-account-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: gitlab-service-account
    namespace: default
```

Configure the kubernetes

```shell
kubectl apply -f gitlab-sa.yml
```

This will create a new service account and attach admin permissions to it. Keep in mind that in production environments you'll definitely want to use a role with only the minimum permissions required.


## S3 Static Website (Manual Creation)

We have already created the S3 bucket for website with help of terraform, this one is optional and use only if you are creating the S3 manually.

* Open the [Amazon S3 console](https://console.aws.amazon.com/s3/).

* create one s3 bucket with any name that you would like to give (better if you can give the service url name itself as bucket name).

* Choose the name of the bucket that you have configured as a static website.

* Choose Permissions.

* Under Block public access (bucket settings), choose Edit.

* Clear Block all public access, and choose Save changes.

* Add a bucket policy (for content publicly available).


```code
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::public-web-content-s3/*"
            ]
        }
    ]
}
```

* enable static website hosting under bucket properties


## Docker Registry

Here I am using dockerhub for storing docker images taht we are going to build from gitlab ci. you can easily create one for free at the [Docker Hub](https://hub.docker.com/) where we can store the docker images.


## Setting up Environment variables in GitLab

We will connect Gitlab with Docker Hub and Kubernetes in our CI/CD, we need to specify some authentication configuration. add the following Environment variables in the gitlab with Protected flag enabled.

### Deployment Environment Variables

* DOCKER_HUB_USER: This is the Docker user you use to login to the Docker Hub.

* DOCKER_HUB_PASSWORD: This is the Docker passwrod you use to login to the Docker Hub.

* K8S_CERTIFICATE_AUTHORITY_DATA: This is the CA configuration for the Kubernetes cluster. (*Get from terraform output*)

* K8S_SERVER: This is the endpoint to the Kubernetes API for our cluster. (*Get from terraform output*)

* K8S_USER_TOKEN: This is the token for the user that we'll use to connect to the Kubernetes cluster. We need to find the token for the user that we created earlier.


### Application Environment Variables

* WEATHER_API_KEY: Api key for accessing the openweather to get the dataset

* AWS_ACCESS_KEY_ID: IAM user key id

* AWS_SECRET_ACCESS_KEY: IAM user key


```shell
kubectl describe secret `kubectl get secrets | grep -i gitlab-service-account-token- | awk '{print $1}'`
```

Copy the token that is part of the output, and enter it in GitLab.



## Validating the kubernetes deployment

* Check the deployment

```shell
kubectl -n dev get cronjobs
kubectl -n dev get configmap
```

* Run a Kubernetes CronJob Manually

if you want a cronjob to be triggered manually, here is what we should do.

```shell
kubectl -n dev create job --from=cronjob/data-collector manual-data-collector-job
```


## My Thoughts on the CI/CD

* I feel Jenkins is better than Gitlab ci for complicated task and faster result. 

* For microservice deployment, Ansible or any other management tools are not required by default.

* Here I am using AWS key and ID for accessing the aws resources such as S3, but we can directly assign one service account to the kubernetes workernode and it can access s3 without any additional authetication. but that will allow all the running pods in the worker node allow to access the resources.

* As long as this is a cronjob deployment on k8s, HA can't be mentioned, but in system level HA is there due to different zone, if it was a deployment then we can configure HA with multiple replica.

* In here, I am not using any domain name for accessing the S3 static web content. this is not recoomented way. because S3 won't allow ssl termination and so we have can use cloudfront, then creating a CNAME in the root location of bucket will help to fix this issue.

* We are using alpine docker images here to reduce the disk space and this will help us getting to secure application

* The docker image tags are getting created with the commit ID and storing the previous versions as well, which will help us to do rolling stratergy in kubernetes deployment if we encounter any issues.