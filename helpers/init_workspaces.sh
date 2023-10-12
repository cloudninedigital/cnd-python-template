#!/usr/bin/env bash

# Check if terraform is installed
if ! command -v terraform &> /dev/null
then
  echo "Terraform could not be found."
  exit 1
fi

# Create development workspace if it doesn't exist
terraform -chdir="terraform" workspace new dev

# Create staging workspace if it doesn't exist
terraform -chdir="terraform" workspace new stg

# Create production workspace if it doesn't exist
terraform -chdir="terraform" workspace new prd

# Create shared workspace if it doesn't exist
terraform -chdir="terraform" workspace new shared

# Change to development workspace
terraform -chdir="terraform" workspace select dev