![Unravel](https://www.unraveldata.com/wp-content/themes/unravel-child/src/images/unLogo.svg)  
# GCP Resource Creation and Configuration for Unravel Bigquery Integration
![Terraform Workflow](https://github.com/unraveldata-org/unravel-terraform-scripts/actions/workflows/run-prcheck.yml/badge.svg)

Project for managing Unravel Bigquery GCP resource configuration! This project aims to simplify the process of setting up and managing Google Cloud resources using Terraform. Below are the instructions to get started:

## Prerequisites
Before proceeding with the installation, ensure that you have the following packages installed on your system:

```bash
git
curl
vim
```
The GCP user running this terrafrom script should have the following permissions.

```bash
iam.roles.create
iam.roles.delete
iam.roles.get
iam.roles.list
iam.roles.undelete
iam.roles.update
iam.serviceAccountKeys.create
iam.serviceAccountKeys.delete
iam.serviceAccountKeys.get
iam.serviceAccounts.create
iam.serviceAccounts.delete
iam.serviceAccounts.get
iam.serviceAccounts.getIamPolicy
iam.serviceAccounts.setIamPolicy
logging.sinks.create
logging.sinks.delete
logging.sinks.get
pubsub.subscriptions.create
pubsub.subscriptions.delete
pubsub.subscriptions.get
pubsub.subscriptions.update
pubsub.topics.attachSubscription
pubsub.topics.create
pubsub.topics.delete
pubsub.topics.get
pubsub.topics.getIamPolicy
pubsub.topics.setIamPolicy
resourcemanager.projects.get
resourcemanager.projects.getIamPolicy
resourcemanager.projects.setIamPolicy
serviceusage.services.disable
serviceusage.services.enable
serviceusage.services.list
```


### Download Terraform
To download and install Terraform, follow these steps:

Visit https://www.terraform.io/downloads to access the Terraform downloads page and the instructions to install terraform.

### Configure gcloud
Before using this project, you need to authenticate with Google Cloud using gcloud. Follow the instructions provided at https://cloud.google.com/sdk/docs/install-sdk for a one-time configuration. You can find the installation instruction based on the Machine Arch and OS installed in the above link.

### Initialize gcloud
To authenticate gcloud, execute the following commands:

```bash
gcloud init
gcloud auth application-default login
```
## Configuration and Installation
Unravel requires few permissions to access Bigquery API/Logs from the GCP projects to generate insights. These project can be classified in to 5 based on the characteristics.

1. Monitoring projects: Projects where Bigquery jobs are running and needs to be integrated with Unravel. Mostly all the projects will come under this.
2. Admin Project: Project(s) where Bigquery Slot reservations/Commitments are defined. This Project may or may not be running Bigquery jobs.
3. Unravel Projects: The Project where Unravel VM is installed. It may or may not be running Bigquery jobs. 
4. Data Page Projects: The Project(s) where Data page needs to be enabled.
5. Billing Project: The Project where Cloud Billinf exports are configured.

## Understanding the Configuration Modes
In order to generate valuable insights, Unravel requires access to Bigquery logs, API, and information schema from the Bigquery projects. Two essential configuration modes need to be considered:

1. Data Polling Mode: This mode determines how data is collected.
    1. Information Schema-based Polling
    2. API-based Polling
2. Authentication Modes: This mode specifies the methods of authentication to be employed.
    1. VM Identity based authentication.
    2. Single Key based authentication.
    3. Multiple Key based authentication.

## Choosing a Data Polling Mode.
Unravel offers two methods for polling data from BigQuery in Google Cloud Platform (GCP) to generate insights:

   1. Information Schema-based Polling
   2. API-based Polling

### Information Schema-based Polling
In this data source polling method, Unravel is granted permissions to run queries on the Information Schema of each BigQuery GCP project. This allows Unravel to gather the necessary information about each job. Additionally, Unravel utilizes GCP API to enrich the data. From the GCP resource perspective, only an IAM role and service account need to be created.

### API-based Polling
In this data source polling method, Unravel uses Google Cloud Logging and filters the data using log sink and log router. The filtered data is then consumed through PubSub topics either as a pull or push method. For this method, you need to ensure that the following resources are created for each project in GCP:

   1. Sink
   2. Log router
   3. PubSub topic
   4. Subscription
   5. IAM roles
   6. Service accounts

## Choosing an Authentication Mode.
Unravel supports three different authentication models for querying BigQuery API/logs:

1. VM Identity based authentication.
2. Single Key based authentication.
3. Multiple Key based authentication.

### VM Identity based authentication.
In this authentication model, A "Master service account" will be created under the "Unravel Project" and IAM roles will be created in each "Monitoring projects", "Admin Projects" and "Unravel Projects". Finally, these roles will be bound to the "Master Service account" created under the "Unravel Project".

The next step involves assigning the "Master Service account" to the Unravel VM. After Terraform creates the required resources, you must perform a one-time manual task: Stop the Unravel VM, change the Service account to the "Master Service account," and then restart the VM and Unravel.

### Single Key based authentication.
Similar to the VM Identity-based authentication model, a "Master service account" is created under the "Unravel Project," and IAM roles are set up in each "Monitoring Project," "Admin Project," and "Unravel Project." These roles are associated with the "Master Service account" in the "Unravel Project."

However, in this model, instead of assigning the "Master service account" to the VM, we generate a key for the "Master Service account." This key will be used by Unravel to gain access.

### Multiple Key based authentication.
In the Multikey based authentication model, an IAM role and a service account will be created in each project (Monitoring, Admin, and Unravel Projects). These roles and service accounts will be associated with one another, and a key will be generated for each project.

Choose the authentication model that best fits your requirements, 

## Create Terraform Input File
Begin by duplicating the provided example input file, input.tfvars.example, and renaming it as input.tfvars. This will serve as your working copy, where you'll input your specific project details.

```bash
git clone https://github.com/unraveldata-org/unravel-terraform-scripts.git
cd unravel-terraform-scripts/bigquery/
cp input.tfvars.example input.tfvars
```
## Creating resources for  Information schema based polling mode.
The following parameter decides the polling mode that needs to be configured. 

**polling_mode** (Required)(string): This parameter is crucial for determining how data is retrieved. Possible values are "schema" for Information schema based data polling, "pull/push" for APi based data polling.

```bash
polling_mode="schema"
```
## Creating resources for API based polling mode.
The following parameter decides the polling mode that needs to be configured. 

**polling_mode** (Required)(string): This parameter is crucial for determining how data is retrieved. Possible values are "schema" for Information schema based data polling, "pull/push" for APi based data polling.

```bash
polling_mode="pull"
```
NOTE: Another model is "push" mode. This required an external publically accessing endpoint to be made available.

### Creating resources for VM Identity based authentication.
Following variables should be updated.

**unravel_project_id** (Required)(string): This variable should contain the GCP Project ID where the Unravel VM is installed. It is crucial to accurately specify this ID for successful integration with Unravel.

**monitoring_project_ids** (Required)(map): Here, you must provide a map of GCP Project IDs(key) and the corresponding PubSub subscription name(values) to be created in these projects. These projects are where the BigQuery Jobs are running and need monitoring. Ensure that all relevant projects are included in this list. 

**admin_project_ids** (Optional)(list): If your setup involves Admin Projects where BigQuery slot reservations are configured, provide a list of their GCP Project IDs in this variable. Otherwise, leave it empty or omit it.

**key_based_auth_model** (Required)(bool) : Set this variable as `false` 

**NB:** Once created, locate the service account name created by terraform using the following command and attach that service account to Unravel VM manually. This requires the VM to be shutdown and restarted.

```bash
terraform output unravel_service_account
```
### Creating resources for Single Key based authentication.
Following variables should be updated.

**unravel_project_id** (Required)(string): This variable should contain the GCP Project ID where the Unravel VM is installed. It is crucial to accurately specify this ID for successful integration with Unravel.

**monitoring_project_ids** (Required)(map): Here, you must provide a map of GCP Project IDs(key) and the corresponding PubSub subscription name(values) to be created in these projects. These projects are where the BigQuery Jobs are running and need monitoring. Ensure that all relevant projects are included in this list. 

**admin_project_ids** (Optional)(list): If your setup involves Admin Projects where BigQuery slot reservations are configured, provide a list of their GCP Project IDs in this variable. Otherwise, leave it empty or omit it.

**key_based_auth_model** (Required)(bool) : Set this variable as `true` 

### Creating resources for Multi Key based authentication.
Following variables should be updated.

**monitoring_project_ids** (Required)(map): Here, you must provide a map of GCP Project IDs(key) and the corresponding PubSub subscription name(values) to be created in these projects. These projects are where the BigQuery Jobs are running and need monitoring. Ensure that all relevant projects are included in this list. 

**admin_project_ids** (Optional)(list): If your setup involves Admin Projects where BigQuery slot reservations are configured, provide a list of their GCP Project IDs in this variable. Otherwise, leave it empty or omit it.

**key_based_auth_model** (Required)(bool) : Set this variable as `false` 

**multi_key_auth_model** (Required)(bool) : Set this variable as `true`

### Creating resources for Data Page Projects.
To enable Unravel Data Insights for Bigquery, it's necessary to set up resources for data page projects. Data Page requires specific permissions to access and gather information for generating insights.

**datapage_project_ids** (Optional)(list): Provide a list of GCP Project IDs that you want to configure for Unravel Data Insights.

### Creating resources for Billing Projects.
Unravel also requires access to the Cloud Billing exports table to provide valuable cost insights. This access involves specific permissions and configurations.

**billing_project_id** (Optional)(string): Specify the GCP Project ID where GCP Cloud billing export is configured.

## Configuring Terraform Backend.(Optional)
It is always recommended to keep the state file in a central storage. Please configure `backend.tf` file in the repo to use Google Storage as your Terraform state file storage.

```bash
cp backend.tf.example backend.tf
```
Update the file with an already existing Google Storage Path where the user executing the terraform have access to.

## Run Terraform to Create Resources
Run Terraform commands in the terraform directory:
``` bash
cd unravel-terraform-scripts/bigquery/
terraform init
terraform plan --var-file=input.tfvars
terraform apply --var-file=input.tfvars
```
## Configuring GCP resources with Unravel
After creating the resources, it has to be configured with Unravel.

The process of configuring Google Cloud Platform (GCP) resources through Unravel is elucidated in the following sections.

### Configuring for Information Schema based data polling mode with Unravel
To configure the system for Information schema based polling mode, the subsequent commands has to be executed.

```bash
/opt/unravel/manager config bigquery set-mode schema
```

### Configuring for API based data polling mode with Unravel
To configure the system for API based polling mode, the subsequent commands has to be executed.

```bash
/opt/unravel/manager config bigquery set-mode pull
```

### Configuring for VM Identity based authentication with Unravel
To establish VM identity-based authentication with Unravel, the subsequent commands has to be executed.

1. Set the authentication mode for the system and furnish the Unravel project ID.
```bash
<Unravel_installation_path>/manager config bigquery set-auth-mode vm --project <unravel_project_id> --no-integration 
```
2. Integrate Monitoring projects into Unravel.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> <unravel_subscription_name>
 ```
3. Incorporate Admin projects into Unravel.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> --is-admin --no-monitoring 
```
4. Add an Admin project that also serves as a Monitoring project.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> <unravel_subscription_name> --is-admin
```
5. Apply configuration changes and restart Unravel.
```bash
<Unravel_installation_path>/manager config apply --restart 
```


### Configuring for Single Key based authentication with Unravel
To establish Single key based authentication with Unravel, the subsequent commands has to be executed.

1. Set the authentication mode for the system and furnish the Unravel project ID
```bash
<Unravel_installation_path>/manager config bigquery set-auth-mode single --project <unravel_project_id> --credentials-file <path_to_credentials_file> --no-integration 
```
2.  Integrate Monitoring projects into Unravel.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> <unravel_subscription_name> 
 ```
3. Incorporate Admin projects into Unravel.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> --is-admin --no-monitoring 
```
4. Add an Admin project that also serves as a Monitoring project.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> <unravel_subscription_name> --is-admin 
```
5. Apply configuration changes and restart Unravel.
```bash
<Unravel_installation_path>/manager config apply --restart 
```

The "path_to_credentials_file" will be accessible through the Terraform output and can also be located in the "./keys/" directory.
Since this authentication method employs a single key, one file can be utilized for all projects.

### Configuring for Multi Key based authentication.
To establish Multi key based authentication with Unravel, the subsequent commands has to be executed.

1.  Set the authentication mode for the system and furnish the Unravel project ID
```bash
<Unravel_installation_path>/manager config bigquery set-auth-mode multi --no-integration 
````
2. Integrate Monitoring projects into Unravel.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> <unravel_subscription_name> --credentials-file <path_to_credentials_file>
 ```
3. Incorporate Admin projects into Unravel.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> --is-admin --no-monitoring --credentials-file <path_to_credentials_file>
```
4. Add an Admin project that also serves as a Monitoring project.
```bash
<Unravel_installation_path>/manager config bigquery add <project_id> <unravel_subscription_name> --is-admin --credentials-file <path_to_credentials_file>
```
5. Apply configuration changes and restart Unravel.
```bash
<Unravel_installation_path>/manager config apply --restart 
```

The "path_to_credentials_file" will be accessible through the Terraform output and can also be located in the "./keys/" directory. 
As Multi Key-based authentication generates a unique key for each added project, please utilize the respective key file named after the project ID.

### Configuring Datapage.
To configure GCP projects for Unravel data insights the subsequent commands has to be executed.

```bash
/opt/unravel/manager config bigquery enable-datapage <project_id>
```

Apply configuration changes and restart Unravel.
```bash
<Unravel_installation_path>/manager config apply --restart 
```

### Configuring Billing.
To enable Unravel Cost insights the subsequent commands has to be executed.

```bash
/opt/unravel/manager config bigquery set-billing-data <project_id> <dataset_id> <table_name>
```

Apply configuration changes and restart Unravel.
```bash
<Unravel_installation_path>/manager config apply --restart 
```

## List the Resources Created by Terraform
To view a list of resources created by Terraform, execute the following command:

```bash
terraform output
```

**VM Identity-Based Authentication**:
In this authentication mode, the authentication process relies on the Service Account. A service account will be created and is available through the Terraform output. To retrieve the service account name, you can use the following command:
```
terraform output unravel-service-account
```
To implement this, follow these steps:
- Access the Terraform output to identify the generated service account.
- Halt the VM.
- Attach the generated service account to the VM.
- Restart the VM to establish authenticated access.

**Single Key-Based Authentication** :
In this authentication method, a single authentication key will be generated and stored within the designated 'keys' directory, which is the default path. This key can be used to authorize access across various projects.
To retrieve the key path, you can execute the following command:
```
terraform output unravel_keys_location
```
**Multi Key-Based Authentication**
In this authentication mode, a collection of keys will be generated within the 'keys' directory, which is the default path. Each key's name will correspond to the project it grants access to.
To retrieve the key path, execute the following command:
```
terraform output unravel_keys_location
```


## Destroy the Resources Created by Terraform
It is possible to eliminate resources either entirely or partially.

### Removing from Unravel
To remove projects from Unravel, use the remove command.

```bash
<Unravel_installation_path>/manager config bigquery remove <project_id>
<Unravel_installation_path>/manager config apply --restart
```

### Removing Unravel Resources from Monitored projects
Modify the input.tfvars file accordingly to exclude the designated project(s), then proceed to rerun  Terraform.  

```bash
terraform apply --var-file=input.tfvars
```

### Remove ALL resources [ CAUTION ]
To remove all changes made through Terraform, execute the following command:

```bash
cd bigquery
terraform destroy --var-file=input.tfvars
```


## Documentation
All documentation for Unravel can be found on our webpage:
https://docs.unraveldata.com

## Support and Feedback
If you encounter any issues or have questions during the integration process, don't hesitate to reach out to our support team at support@unraveldata.com. We are here to assist you and ensure a successful setup.

We value your feedback! If you have any suggestions or improvements to contribute to this repository, please feel free to open an issue or submit a pull request.

Thank you for choosing Unravel for your big data observability needs. We are excited to help you optimize your big data applications and enhance your data platform's performance and efficiency. Happy Unraveling!

