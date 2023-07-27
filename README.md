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

## 3. Install Terraform and Cloud SDK CLI

At Cloud Nine Digital we use Terraform authenticated by Google Cloud credentials to deploy our resources in a GCP.

[Terraform](https://www.terraform.io/) is an IaC (Infrastructure as Code) tool that allows for reusable and trackable Cloud infrastructure deployments.
For more information about Terraform please visit their [Introduction](https://developer.hashicorp.com/terraform/intro).

[Google Cloud CLI](https://cloud.google.com/cli) (Command Line Interface) is a command-line interface that allows for interaction and creation of
Google Cloud resources. In this particular case, we use it to enable authentication of Terraform, and not to create resources through it.

Before continuing please take the following steps: 
* [Install](https://cloud.google.com/sdk/docs/install) and 
[initialize](https://cloud.google.com/sdk/docs/initializing) your Google Cloud CLI. Make sure to authenticate
into the right Google Cloud project ID while initializing. 
* [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli?in=terraform%2Fgcp-get-started).

The configuration files for Terraform can be found in the `terraform/` folder.

## 4. Create a bucket to store the terraform configuration state
It is good practice to store the terraform config in a bucket existing in the 
same project as all the other resources. To do this:
1. Change the `terraform/remote-state/variables.tf` to something like:
```terraform
variable "project" {
  description = "Project ID"
  type = string
  default = "<PROJECT-ID-YOU-ARE-WORKING-WITH>"
}
```
2. Go to your command line and navigate to the `terraform/remote-state` folder.
This will be the folder in your you cloned your repository.
```bash
$ cd <my-project-folder>/terraform/remote-state
```

3. Initialize terraform with the following command:
```bash
$ terraform init
```

4. Apply the terraform configuration for the remote state bucket. 
```bash
$ terraform apply
```
4. Type __yes__ when prompted to confirm the changes
5. Copy the output value given by terraform on the variable `terraform_state_bucket`
6. Change the file `terraform/backend.tf` to reflect your new bucket containing the state
```terraform
terraform {
  backend "gcs" {
    # TODO
    bucket = "<NAME_OF_BUCKET_COPIED_IN_STEP_5>"
    prefix = "terraform/state"
  }
}
```
7. __TODO add here instructions for optional terraform state locking__
8. Go back to your terminal and initialize terraform with the following command:
````bash
$ terraform init
````

9. Run the workspace generation script
```bash
$ ./helpers/init_workspaces.sh
```
You should see that the staging and production workspaces have been created.


If all goes well, your bucket is now the central storage for the terraform state. Like this, all developers collaborating
in this project will have access to the same terraform state.


## 5. Start development work

This is where your development journey begins. From here on the steps are highly dependent on the functionality
you are trying to deploy in the cloud. 

There are two main parts to this work:
1. Building your Python code
2. Building your Terraform configuration to deploy that code (as well as additional infrastructure that supports it).

See below for a few more details on both parts:


### 5.1 Making CND internal dependencies installable
> **Note** This step is not necessary if you are not intending to use any `cnd_tools` functionality. If you skip this step,
> remember to remove the necessary lines from `requirements.txt` (usually the two first lines starting with "--extra-index-url" and
> the import of `cnd-tools`.)


For being able to deploy your code using internal dependencies from CND, we need to enable the Google Cloud Project
that you are working on to be able to install these packages. At the time of writing, the only package that is provided
internally is [cnd-tools](https://github.com/cloudninedigital/cnd-tools). You will notice that the file `requirements.txt`
is already configured with the [CND Artifact Registry for python packages](https://console.cloud.google.com/artifacts/python/cloudnine-digital/europe-west4/cnd-tools-repo?project=cloudnine-digital).

This is however, not sufficient, as you are working in a different project than the one where the repository is located.
For this to work, the Cloud Build service account of your project needs to be given role **Artifact Registry Reader**
role in the original project hosting the python package registry.

If you are up for using terraform for this step, please follow the instructions in 
[this repo](https://github.com/cloudninedigital/cnd-cloudninedigital-terraform#giving-permissions-to-download-python-packages-in-a-client-project).
Note that managing these permissions with terraform is not mandatory, but it is recommended for the sake of consistency.
Otherwise, follow the instructions below:

* Go to the project [cloudnine-digital](https://console.cloud.google.com/home/dashboard?project=cloudnine-digital).
* Navigate to **IAM**
* Click **Grant Access**
* Add the Cloud Build service account _of your client project_ as a new principal. The Cloud Build default service 
account is `PROJECT_NUMBER@cloudbuild.gserviceaccount.com`. Note that here we use the _project number as opposed 
to the project ID_. This project number belongs to the project you are deploying this current project to.
* Give it **Artifact Registry Reader** role.

See relevant documentation [here](https://cloud.google.com/artifact-registry/docs/integrate-functions).

> **Note for users** For reasons not known at the moment of writing, installing `cnd_tools` with a runtime environment `python311`
> is not functional due to an incompatibility between the `pandas` library and Cloud Build engine. Please use `python310`
> for now.


## 5.2 Link GitHub repo into a Google Cloud Source repo

### CAUTION: THIS PART HAS PROBABLY BECOME IRRELEVANT DUE TO AUTOMATED DEPLOYMENTS and usage of the GCP ZIP archive option for cloud functions!
This step is necessary before you can deploy any Cloud Functions to GCP.
The Cloud Function configurations in our ETL template are set to use a source repository as a code source.

For this to work, you need to link the GitHub repository that you are working on into Google Cloud Source repositories.

Please take the following steps:
1. Go to https://source.cloud.google.com/.
2. Click **Add repository** (top-right of the window).
3. Click **Connect external repository**.
4. Type in (or seach for) your GCP project id.
5. Choose **GitHub** as the Git provider.
6. Authorize the storage of your credentials in Google Cloud.
7. Click **Connect to GitHub**.
8. Choose the GitHub repository that you wish to mirror.
9. Click **Connect selected repository**

> **Note**: This process is relevant for 1st gen Cloud Build repositories. Soon the CND developers
> will automate the connection of 2nd gen Cloud Build repositories, rendering the step 5.3 obsolete.

## 5.3 Enable automated deployment on Gitlab or GitHub

For Gitlab, the below steps can be followed:

1. In your GCP project console, create a new service account (named something along the lines of terraform-gitlab-executor)
2. Provide this service account with the basic role 'Editor', and the 'Security Admin' role. 
3. When the account is created, Create and download a JSON key file to your local laptop
4. with a bash shell on your local laptop, do the following to remove line endings from the file: 
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
5a. **If you are using GitLab**, open your repository, go to Settings > CI/CD, expand Variables and create a new 
variable with the key GOOGLE_CREDENTIALS, and paste the contents of your changed keyfile as the value. 
Make sure all 'flags' (protected, masked and expanded variable) are turned off, you don't need this. 
Also make sure that Environment scope stays on 'All'. 
5b. **If you are using GitHub**, in your repository, go to **Settings** → **Secrets and Variables** → **Actions** -> New repository secret, and 
create a secret named GOOGLE_CREDENTIALS, and paste the contents of your changed keyfile as the value. 
6a. **If you are using GitLab**, in your local repository, go to .gitlab-ci.yml and 
uncomment the whole script ( CTRL+A and CTRL+/)
6b. **If you are using GitHub**, in your local repository, go to .github/workflows/terraform.yml and uncomment the whole 
script ( CTRL+A and CTRL+/)
7. Make sure your variables are all added as intended in prd.tfvars, stg.tfvars and dev.tfvars
8. Push your changes. You will notice that on a separate branch the pipeline will only run until 'terraform plan'. 
The 'terraform apply', and thus the actual deployment will only be done when merging / pushing to the 
'main' or 'development' branches or when a tag is pushed. 

## 5.4 Terraform configuration

There a few examples of deployments of Cloud Functions present in the folder
`terraform/modules/main_triggers`. From one of these files, you can copy the contents and paste it onto your `terraform/main.tf`.

This will provide you with a starting point for the configuration you are trying to achieve. Please read the documentation of 
each one of these modules before you use them, to avoid surprises in your development process.

Please see more detailed information in [Terraform templates usage](terraform_usage.md).

To extend your Terraform configuration, you will have to start dwelling into un-templated territory :relaxed:.
Please follow a few [Getting Started with Google Cloud in Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)
tutorials to get acquainted with the system.

### 5.5 Python code
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


### 5.6 Deploying your code

If you have followed step 5.3, then your deployments are automated in the following manner:
* Any commits pushed to `main` branch will be deployed to staging environment
* Any tags pushed will be deployed to production environment
* If there is a `development` branch, then any push made to it is deployed to development environment

> **WARNING** Pushing tags to branches other than main might result in unexpected behaviour.
> Please refrain from doing so.

> **WARNING** Pushing tags to commits that are done earlier than previous tags will result in deployment that tag 
> to production environment.