# Python Project Template for APIs

A repository that serves as a template for deploying small pipelines and 
Cloud Functions in GCP (Google Cloud Platform).

This template uses Python for implementing all the logic deployed in your GCP 
Functions and Terraform as a deployment system.


# How use the ETL template

## 1. Starting a new repository from this template

> **DO NOT FORK** this is meant to be used from **[Use this template](https://github.com/cloudninedigital/cnd-etl-template/generate)** feature.

1. Click on **[Use this template](https://github.com/cloudninedigital/cnd-etl-template/generate)**
2. Give a name to your project. See [naming conventions](https://github.com/cloudninedigital)
3. Wait until the first run of CI (Continuous Integration) finishes  
   (Github Actions will process the template and commit to your new repo)
4. Then clone your new project and happy coding!

## 2. Clone your project

Follow [these instructions](https://wiki.cloudninedigital.nl/en/Processing-and-Delivery/Software-Development/Git/Getting-started-with-Git#cloning-an-existing-repository-from-a-remote-repository) 
to clone a repository created on Github.

## 3. Install Terraform, Cloud SDK CLI and GitHub CLI

At Cloud Nine Digital we use Terraform authenticated by Google Cloud credentials to deploy our resources in a GCP.

[Terraform](https://www.terraform.io/) is an IaC (Infrastructure as Code) tool that allows for reusable and trackable Cloud infrastructure deployments.
For more information about Terraform please visit their [Introduction](https://developer.hashicorp.com/terraform/intro).

[Google Cloud CLI](https://cloud.google.com/cli) (Command Line Interface) is a command-line interface that allows for interaction and creation of
Google Cloud resources. In this particular case, we use it to enable authentication of Terraform, and not to create resources through it.

[GitHub CLI](https://cli.github.com/) is a command-line interface that allows for interaction with GitHub repositories. 
In this particular case, we use it to enable authentication of Terraform in our CI/CD pipelines.

Before continuing please take the following steps: 
* [Install](https://cloud.google.com/sdk/docs/install) and 
[initialize](https://cloud.google.com/sdk/docs/initializing) your Google Cloud CLI. Make sure to authenticate
into the right Google Cloud project ID while initializing. 
* [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli?in=terraform%2Fgcp-get-started).
* [Install GitHub CLI](https://cli.github.com/).

The configuration files for Terraform can be found in the `terraform/` folder.

# 4. Run initialization script
> Note: If you wish to do this manually, please follow the instructions in [manual_init.md](manual_init.md)

Run the following command to initialize your project:
```bash
$ ./helpers/init_project.sh
```

> Note: The script will help you check the status of installation of the necessary tools.
> It will not install them for you, but if they are installed they will be used.
> Furthermore it will check if these tools are properly authenticated, and if not it will help you authenticate them.

The script will prompt you for the following information:
* Your GCP project ID
* Whether you want to enable GitHub CI/CD


## 5 Enable automated deployment on Gitlab or GitHub
> Note: This step is already done for GitHub if you have run the `helpers/init_project.sh` script.
> For Gitlab you will have to do this manually (for now :smile:) 

For Gitlab, the below steps can be followed:
1. Assuming you've executed step 4 properly, you've already created a service account called terraform-agent@<project-id>.iam.gserviceaccount.com with the proper rights to do a deployment. In the 'Service Accounts' section, go to this service account, and create and download a JSON key file to your local laptop.
2. with a bash shell on your local laptop, do the following to remove line endings from the file:
``` bash
vi gcp-keyfile.json
# press :

# Add the following 
%s;\n; ;g
# Press enter.

# press : again

# Execute the below command to save and close the editor
wq!
```
3a. **If you are using GitLab**, open your repository, go to Settings > CI/CD, expand Variables and create a new
variable with the key GOOGLE_CREDENTIALS, and paste the contents of your changed keyfile as the value.
Make sure all 'flags' (protected, masked and expanded variable) are turned off, you don't need this.
Also make sure that Environment scope stays on 'All'.
3b. **If you are using GitHub**, in your repository, go to **Settings** → **Secrets and Variables** → **Actions** -> New repository secret, and
create a secret named GOOGLE_CREDENTIALS, and paste the contents of your changed keyfile as the value.
4a. **If you are using GitLab**, in your local repository, go to .gitlab-ci.yml and
uncomment the whole script ( CTRL+A and CTRL+/)
4b. **If you are using GitHub**, in your local repository, go to .github/workflows/terraform.yml and uncomment the whole
script ( CTRL+A and CTRL+/)
5. Make sure your variables are all added as intended in prd.tfvars, stg.tfvars and dev.tfvars
6. Push your changes. You will notice that on a separate branch the pipeline will only run until 'terraform plan'.
   The 'terraform apply', and thus the actual deployment will only be done when merging / pushing to the
   'main' or 'development' branches or when a tag is pushed. 

## 6. Start development work

This is where your development journey begins. From here on the steps are highly dependent on the functionality
you are trying to deploy in the cloud. 

There are two main parts to this work:
1. Building your Python code
2. Building your Terraform configuration to deploy that code (as well as additional infrastructure that supports it).

See below for a few more details on both parts:


## 6.1 Terraform configuration

There a few examples of deployments of Cloud Functions present in the folder
`terraform/modules/main_triggers`. From one of these files, you can copy the contents and paste it onto your `terraform/main.tf`.

This will provide you with a starting point for the configuration you are trying to achieve. Please read the documentation of 
each one of these modules before you use them, to avoid surprises in your development process.

Please see more detailed information in [Terraform templates usage](terraform_usage.md).

To extend your Terraform configuration, you will have to start dwelling into un-templated territory :relaxed:.
Please follow a few [Getting Started with Google Cloud in Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)
tutorials to get acquainted with the system.

### 6.2 Python code
To start development, you will have to understand which service in Google Cloud is your code
going to be deployed. To see how you can start coding your entry points, check the relevant folders:
* For Cloud Functions, please the following entrypoints in `project_name/gcp.py`
  * `main_cloud_event` meant to be used for file events on Google Cloud Storage.
  * `main_http_event` meant to be used for http triggers
  * `main_pubsub` meant to be used for Pub/Sub triggers

In order to configure the triggers for Cloud Functions, please see the section on the [Terraform configuration](#terraform-configuration)
section.

> :exclamation: For now there are not pre-made templates for Cloud Run or other services in Google Cloud. This guide is supposed to be
expanded with more examples as we go forward and explore more Cloud services for ETL/ELT processes.




> **NOTE**: **WAIT** until first CI run on github actions before cloning your new project.


### 5.4 Deploying your code

If you have followed step 5 or ran the `helpers/init_project.sh` script, then your deployments are automated in the following manner:
* Any commits pushed to `main` branch will be deployed to staging environment
* Any tags pushed will be deployed to production environment
* If there is a `development` branch, then any push made to it is deployed to development environment

> **WARNING** Pushing tags to branches other than main might result in unexpected behaviour.
> Please refrain from doing so.

> **WARNING** Pushing tags to commits that are done earlier than previous tags will result in deployment that tag 
> to production environment.