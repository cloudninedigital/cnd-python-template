# Python Project Template for APIs

A repository that serves as a template for deploying small pipelines and 
Cloud Functions in GCP.

This template uses Python for implementing all the logic deployed in your GCP 
Functions and Terraform as a deployment technique.


# How use the ETL template

## 1. Starting a new repository from this template

> **DO NOT FORK** this is meant to be used from **[Use this template](https://github.com/cloudninedigital/cnd-etl-template/generate)** feature.

1. Click on **[Use this template](https://github.com/cloudninedigital/cnd-etl-template/generate)**
2. Give a name to your project. See [naming conventions](https://github.com/cloudninedigital)
3. Wait until the first run of CI finishes  
   (Github Actions will process the template and commit to your new repo)
4. Then clone your new project and happy coding!

## 2. Clone your project

Follow [these instructions](https://wiki.cloudninedigital.nl/en/Processing-and-Delivery/Software-Development/Git/Getting-started-with-Git#cloning-an-existing-repository-from-a-remote-repository) 
to clone a repository created on Github.

## 3. Install Terraform and Cloud SDK CLI

This project contains a few templates for Google Cloud resources. These are
configured by [Terraform](https://www.terraform.io/) to facilitate version control on the Cloud infrastructure.

Before continuing please [install](https://cloud.google.com/sdk/docs/install) and 
[initialize](https://cloud.google.com/sdk/docs/initializing) your Google Cloud SDK. Make sure to authenticate
into the right Google Cloud project ID.

Additionally you will also need to [install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli?in=terraform%2Fgcp-get-started).

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

### Python code
To start development, you will have to understand which service in Google Cloud is your code
going to be deployed. To see how you can start coding your entry points, check the relevant folders:
* For Cloud Functions, please see ...

### Terraform configuration

There a few examples of deployments of Cloud Functions present in the folder
`terraform/main_examples`. From one of these files, you can copy the contents and paste it onto your `terraform/main.tf`.

This will provide you with a starting point for the configuration you are trying to achieve. Please read the documentation of 
each one of these modules before you use them, so as to avoid surprises in your development process.

To extend your Terraform configuration, you will have to start dwelling into un-templated territory :relaxed:.
Please follow a few [Getting Started with Google Cloud in Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)
tutorials so as to get acquainted with the system.

## 6. Implement your Python code


