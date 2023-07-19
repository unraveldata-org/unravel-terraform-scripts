# Unravel Bigquery GCP resource configuration.

## Pre-Requisite

```bash
yum install curl vim -y
```

## Download Terraform
Instructions to download terraform
https://www.terraform.io/downloads

Download the version according to the machine arch.

```bash
unzip terraform_1.2.4_linux_amd64.zip
cp terraform /bin/terraform
chmod 755 /bin/terraform
```

## Configure gcloud
One time configuration needed to authenticate to gcloud
Ref: https://cloud.google.com/sdk/docs/install-sdk

## Configure Yum repo to install gcloud
```bash
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
```
### Install gcloud
```bash
yum install google-cloud-cli -y
```

### Initialize gcloud
Execute this command and use your local terminal/browser to login.
```bash
gcloud init
gcloud auth application-default login
```

## Create terraform input file
Copy the template file and update the file with GCP project IDs and Push endpoint.

```bash
cp input.tfvars.example input.tfvars
```

## Run Terraform to create resources
To setup a GCP project, add the project ID to variables.tf file and run the below terraform command.
```bash
cd terraform
terraform init 
terraform plan --var-file=input.tfvars 
terraform apply --var-file=input.tfvars 
```
## Terraform DAG
![Terraform DAG](graph.svg)

## List the resources created by Terraform

```bash
terraform output
```

## Destroy the resources created by Terraform
Destroys all changes done through terrafrom, run the below terraform command.
```bash
cd terraform
terraform destroy --var-file=input.tfvars
```
