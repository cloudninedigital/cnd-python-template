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

3. Apply the terraform configuration for the remote state bucket. 
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
role in the original project hosting the python package registry: 
* Go to the project [cloudnine-digital](https://console.cloud.google.com/home/dashboard?project=cloudnine-digital).
* Navigate to **IAM**
* Click **Grant Access**
* Add the Cloud Build service account _of your client project_ as a new principal. The Cloud Build default service 
account is `PROJECT_NUMBER@cloudbuild.gserviceaccount.com`. Note that here we use the _project number as opposed 
to the project ID_. This project number belongs to the project you are deploying this current project to.
* Give it **Artifact Registry Reader** role.

See relevant documentation [here](https://cloud.google.com/artifact-registry/docs/integrate-functions).

> **Note for template developers** As we advance further, this IAM management should move to a `cloudnine-digital`
> project specific terraform.


> **Note for users** For reasons not known at the moment of writing, installing `cnd_tools` with a runtime environment `python311`
> is not functional due to an incompatibility between the `pandas` library and Cloud Build engine. Please use `python310`
> for now.


## 5.2 Link GitHub repo into a Google Cloud Source repo

### CAUTION: THIS PART HAS PROBABLY BECOME IRRELEVANT DUE TO AUTOMATED DEPLOYMENTS!
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

### 5.3 Terraform configuration

There a few examples of deployments of Cloud Functions present in the folder
`terraform/modules/main_triggers`. From one of these files, you can copy the contents and paste it onto your `terraform/main.tf`.

This will provide you with a starting point for the configuration you are trying to achieve. Please read the documentation of 
each one of these modules before you use them, to avoid surprises in your development process.

Please see more detailed information in [Terraform templates usage](terraform_usage.md).

To extend your Terraform configuration, you will have to start dwelling into un-templated territory :relaxed:.
Please follow a few [Getting Started with Google Cloud in Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)
tutorials to get acquainted with the system.

### 5.4 Python code
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

### What is included on this template?

- 🖼️ Templates for starting multiple application types:
  * **Basic low dependency** Python program (default) [use this template](https://github.com/cloudninedigital/cnd-etl-template/generate)
  * **Flask** with database, admin interface, restapi and authentication [use this template](https://github.com/cloudninedigital/flask-project-template/generate).
  **or Run `make init` after cloning to generate a new project based on a template.**
- 📦 A basic [setup.py](setup.py) file to provide installation, packaging and distribution for your project.  
  Template uses setuptools because it's the de-facto standard for Python packages, you can run `make switch-to-poetry` later if you want.
- 🤖 A [Makefile](Makefile) with the most useful commands to install, test, lint, format and release your project.
- 📃 Documentation structure using [mkdocs](http://www.mkdocs.org)
- 💬 Auto generation of change log using **gitchangelog** to keep a HISTORY.md file automatically based on your commit history on every release.
- 🐋 A simple [Containerfile](Containerfile) to build a container image for your project.  
  `Containerfile` is a more open standard for building container images than Dockerfile, you can use buildah or docker with this file.
- 🧪 Testing structure using [pytest](https://docs.pytest.org/en/latest/)
- ✅ Code linting using [flake8](https://flake8.pycqa.org/en/latest/)
- 📊 Code coverage reports using [codecov](https://about.codecov.io/sign-up/)
- 🛳️ Automatic release to [PyPI](https://pypi.org) using [twine](https://twine.readthedocs.io/en/latest/) and github actions.
- 🎯 Entry points to execute your program using `python -m <project_name>` or `$ project_name` with basic CLI argument parsing.
- 🔄 Continuous integration using [Github Actions](.github/workflows/) with jobs to lint, test and release your project on Linux, Mac and Windows environments.

> Curious about architectural decisions on this template? read [ABOUT_THIS_TEMPLATE.md](ABOUT_THIS_TEMPLATE.md)  
> If you want to contribute to this template please open an [issue](https://github.com/cloudninedigital/cnd-etl-template/issues) or fork and send a PULL REQUEST.

[❤️ Sponsor this project](https://github.com/sponsors/cloudninedigital/)

<!--  DELETE THE LINES ABOVE THIS AND WRITE YOUR PROJECT README BELOW -->

---
# project_name

[![codecov](https://codecov.io/gh/author_name/project_urlname/branch/main/graph/badge.svg?token=project_urlname_token_here)](https://codecov.io/gh/author_name/project_urlname)
[![CI](https://github.com/author_name/project_urlname/actions/workflows/main.yml/badge.svg)](https://github.com/author_name/project_urlname/actions/workflows/main.yml)

project_description

## Install it from PyPI

```bash
pip install project_name
```

## Usage

```py
from project_name import BaseClass
from project_name import base_function

BaseClass().base_method()
base_function()
```

```bash
$ python -m project_name
#or
$ project_name
```

## Development

Read the [CONTRIBUTING.md](CONTRIBUTING.md) file.


# GitHub Actions

[Authentication of Google Cloud in GitHub Actions](https://github.com/marketplace/actions/authenticate-to-google-cloud).
