## 4. Create startup resources: remote-state bucket, base services enabling, terraform CI agent
To startup, we've created a terraform folder that creates some base resources needed by any further deployment to work properly. This includes:
* A remote-state bucket. Terraform stores it's 'state' of all the resources it manages in some place. If you don't specify this, it will store it on your local laptop, which will make collaboration very hard. To avoid this, we create a terraform state GCS bucket that can serve as a state storage space.
* Some base services enabled. To run Terraform deployments from an automated CI flow, some base services need to be enabled for the deployment to actually work. This includes, for example, the cloud resource manager API.
* A terraform agent service account. To run Terraform deployments from an automated CI flow, you'll need a terraform agent service account that has the necessary rights to actually make a deployment. This is also created here.


To create the startup resources:
1. Change the `terraform/local-bootstrap-startup/terraform.tfvars` to something like:
```terraform
project="<yourprojectid>"
```
2. Go to your command line and navigate to the `terraform/local-bootstrap-startup` folder.
   This will be the folder in your you cloned your repository.
```bash
$ cd <my-project-folder>/terraform/local-bootstrap-startup
```

3. Initialize terraform with the following command:
```bash
$ terraform init
```

4. Apply the terraform configuration for the remote state bucket.
```bash
$ terraform apply --var-file="terraform.tfvars"
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
