#!/usr/bin/env bash

###############################################
# [START] Local declarations
###############################################
local_terraform_folder="terraform"
boostrap_terraform_folder="terraform/local-bootstrap-startup"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function list_projects() {
  gcloud projects list | awk '{if(NR>1)print}' | grep -v -E 'sys-*|bing-sheet-*|my-project*\|gam-*|gmc-*|quickstart-*|test-*' | nl
}

###############################################
# [END] Local declarations
###############################################

###############################################
# [START] Welcome message
###############################################

echo -e $BLUE
echo "###############################################"
echo "###############################################"
echo "Welcome to the Google Cloud Platform project initializer."
echo "This script will help you to initialize a project for the Google Cloud Platform."
echo "Please make sure you have the following tools installed:"
echo "1. gcloud"
echo

echo "###############################################"
echo "Please make sure you have initialized gcloud with the following command:"
echo "gcloud init"
echo

echo "###############################################"
echo "Please make sure you have the following permissions:"
echo "1. roles/editor"
echo "2. roles/securityAdmin"
echo -e $NC

###############################################
# [END] Welcome message
###############################################

###############################################
# [START] Check if gcloud is installed
###############################################

# Check if gcloud is installed
echo -e "${BLUE}Checking if gcloud is installed...${NC}"
if ! command -v gcloud &> /dev/null
then
    echo -e "${RED}gcloud could not be found. Please install gcloud to continue. See https://cloud.google.com/sdk/docs/install${NC}"
    exit
else
  echo -e "${GREEN}gcloud is installed.${NC}"
fi

# Check the account with which gcloud is logged in
echo -e "${BLUE}Checking if gcloud is logged in...${NC}"
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null
then
    echo -e "${RED}gcloud is not logged in. Please login to continue.${NC}"
    gcloud auth application-default login
else
  echo -e "${GREEN}gcloud is logged in.${NC}"
  account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
  echo "Using account: $account"
  read -p "Do you wish to continue with this account? (y/n) " continue
  if [[ $continue != "y" ]]; then
    echo -e "${GREEN}Continuing with account ${account}.${NC}"
  fi
fi


# Check if gcloud is initialized
echo -e "${BLUE}Checking if gcloud is initialized...${NC}"
if ! gcloud config get-value project &> /dev/null
then
    echo -e "${RED}gcloud is not initialized. Let's initialize it:${NC}"
    gcloud init
else
  echo -e "${GREEN}gcloud is initialized.${NC}"
fi

###############################################
# [END] Check if gcloud is installed
###############################################

###############################################
# [START] Check if terraform is installed
###############################################

# Check if terraform is installed
if ! command -v terraform &> /dev/null
then
    echo -e "${RED}terraform could not be found. Please install terraform to continue. See https://learn.hashicorp.com/tutorials/terraform/install-cli${NC}"
    exit
else
  echo -e "${GREEN}terraform is installed.${NC}"
fi

###############################################
# [END] Check if terraform is installed
###############################################


###############################################
# [START] Check if GitHub CLI is installed
###############################################

echo -e "${BLUE}Checking if GitHub CLI is installed...${NC}"
if ! command -v gh &> /dev/null
then
    echo -e "${RED}gh could not be found. Please install gh to continue. See https://cli.github.com/${NC}"
    exit
else
  echo -e "${GREEN}gh is installed.${NC}"
fi

# Check if logged in

if ! gh auth status &> /dev/null
then
  echo -e "${RED}gh is not logged in. Please login to continue.${NC}"
  gh auth login
else
  echo -e "${GREEN}gh is logged in.${NC}"
fi

###############################################
# [END] Check if GitHub CLI is installed
###############################################

###############################################
# [START] Get project id
###############################################

echo -e "${BLUE}Please choose one of the following options to determine the Google Cloud project id:${NC}"
echo "1. Provide a project_id."
echo "2. Choose a project from a list."
read -p "Select an option from above: " project_option
echo


if [[ $project_option == 1 ]]; then
  read -p "Enter the project_id: " project_id
elif [[ $project_option == 2 ]]; then
  echo -e "${BLUE}Listing projects...${NC}"
  mapfile -t projects < <(list_projects)

  echo "There projects are available:"
  for project in "${projects[@]}"; do
    echo "$project"
  done

  read -p "Enter the number of the project you want to use: " project_number

  project_id=$(echo "${projects[($project_number - 1)]}" | awk '{print $2}')

else
  echo -e "${RED}Invalid option${NC}"
  exit 1
fi

echo "Using project_id: $project_id"
read -p "Do you wish to continue? (y/n) " continue
if [[ $continue != "y" ]]; then
  echo -e "${RED}Aborting...${NC}"
  exit 1
fi
###############################################
# [END] Get project id
###############################################


###############################################
# [START] Initialize remote state and terraform service account
###############################################

echo -e "${BLUE}Initializing remote state and terraform service account...${NC}"
find $local_terraform_folder -type f -name "*.tfvars" -exec sed -i -e "s/\(project\s*=\s*\).*/\1\"${project_id}\"/g" {} \;

terraform -chdir=$boostrap_terraform_folder init
terraform -chdir=$boostrap_terraform_folder apply -var="project=$project_id"

if [[ $? -eq 0 ]]; then
  echo -e "${GREEN}Project initialized successfully.${NC}"
else
  echo -e "${RED}Project initialization failed.${NC}"
  exit 1
fi

###############################################
# [END] Initialize remote state and terraform service account
###############################################

###############################################
# [START] Upload terraform service account credentials to GitHub
###############################################

# Retrieve the service account credentials email
echo -e "${BLUE}Retrieving terraform service account credentials...${NC}"
tf_sa=$(terraform -chdir=$boostrap_terraform_folder output -raw terraform_service_account)

# Retrieve the service account credentials
if [[ -f ./tf_sa_credentials.json ]]; then
  echo "Service account credentials already exist."
  read -p "Do you wish to overwrite the service account credentials? (y/n) " overwrite_credentials
  if [[ $overwrite_credentials == "y" ]]; then
    rm -v ./tf_sa_credentials.json ./tf_sa_credentials.json.tmp
  fi
fi

if [[ ! -f ./tf_sa_credentials.json ]]; then
  echo -e "${BLUE}Downloading service account credentials...${NC}"
  gcloud iam service-accounts keys create ./tf_sa_credentials.json --iam-account=$tf_sa
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Service account credentials downloaded successfully.${NC}"
  else
    echo -e "${RED}Service account credentials download failed.${NC}"
  fi
fi

#Delete newlines from the service account credentials
tr -d '\n' < ./tf_sa_credentials.json > ./tf_sa_credentials.json.tmp

read -p "Do you wish to upload the service account credentials to GitHub? (y/n) " upload_credentials
if [[ $upload_credentials == "y" ]]; then
  # Check if gh is installed
  if ! command -v gh &> /dev/null
  then
      echo -e "${RED}gh could not be found. Please install gh to continue. See https://cli.github.com/${NC}"
      exit
  fi
  # Check if gh is logged in
if ! gh auth status &> /dev/null
  then
    echo -e "${RED}gh is not logged in. Please login to continue.${NC}"
    gh auth login
  fi

  echo -e "${BLUE}Uploading service account credentials to GitHub...${NC}"
  gh secret set GOOGLE_CREDENTIALS < ./tf_sa_credentials.json.tmp
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Service account credentials uploaded successfully.${NC}"
  else
    echo -e "${RED}Service account credentials upload failed.${NC}"
  fi
fi


# If credentials were downloaded, ask used if he wants to delete
read -p "Do you wish to delete the service account credentials from local disk (recommended if upload to GH was successful)? (y/n) " delete_credentials
if [[ $delete_credentials == "y" ]]; then
  echo -e "${BLUE}Deleting service account credentials from local disk...${NC}"
  rm -v ./tf_sa_credentials.json.tmp ./tf_sa_credentials.json
fi

###############################################
# [END] Upload terraform service account credentials to GitHub
###############################################

###############################################
# [START] Configure remote state bucket in backend files
###############################################

# replace the state bucket name in the backend.tf file
tf_bucket=$(terraform -chdir=$boostrap_terraform_folder output -raw terraform_state_bucket)

# remove the begin of line comments from backend.tf files
find $local_terraform_folder -type f -name "backend.tf" -exec sed -i -e "s/^#\+//g" {} \;

find $local_terraform_folder -type f -name "backend.tf" -exec sed -i -e "s/\(bucket\s*=\s*\).*/\1\"${tf_bucket}\"/g" {} \;

###############################################
# [END] Configure remote state bucket in backend files
###############################################

###############################################
# [START] Initialize terraform and workspaces
###############################################

# Initialize terraform and workspaces
terraform -chdir=$local_terraform_folder init
./helpers/init_workspaces.sh

###############################################
# [END] Initialize terraform and workspaces
###############################################

###############################################
# [START] Activate CI/CD pipeline
###############################################
read -p "Do you wish to activate the CI/CD pipeline? (y/n) " activate_cicd
if [[ $activate_cicd == "y" ]]; then
  # Remove comments from the GitHub Actions workflow file
  sed -i -e "s/^#\+//g" ./.github/workflows/terraform.yml
fi

###############################################
# [END] Activate CI/CD pipeline
###############################################

###############################################
# [START] Commit changes to git
###############################################
read -p "Do you wish to commit the changes to git? (y/n) " commit_changes


if [[ $commit_changes == "y" ]]; then
  # If on main branch, create a new branch
  if [[ $(git branch --show-current) == "main" ]]; then
    read -p "You are on the main branch. Do you wish to create a new branch? (y/n) " create_branch
    if [[ $create_branch == "y" ]]; then
      echo "We are going to create a new branch here, please follow our naming conventions."
      echo "The branch name should start with 'feature-' or 'fix-' followed by a short description of the changes."
      echo "Link to our guidelines: https://wiki.cloudninedigital.nl/en/Processing-and-Delivery/Software-Development/Git/Git_Best_Practices"
      read -p "Enter the name of the new branch: " branch_name
      git checkout -b $branch_name
    fi
  fi
  echo -e "${BLUE}Committing changes to git...${NC}"
  git add $local_terraform_folder/*.tfvars
  git add $local_terraform_folder/*/*.tfvars
  git add $local_terraform_folder/backend.tf
  git add $local_terraform_folder/*/backend.tf
  git add $boostrap_terraform_folder
  git add .github/workflows/terraform.yml
  git commit -m"[init_project] Initialized project with terraform."
  git push --set-upstream origin $(git branch --show-current)
fi

###############################################
# [END] Commit changes to git
###############################################

