#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function list_projects() {
  gcloud projects list | awk '{if(NR>1)print}' | grep -v -E 'sys-*|bing-sheet-*|my-project*\|gam-*|gmc-*|quickstart-*|test-*' | nl
}

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





echo -e "${BLUE}Please choose one of the following options to determine the project id:${NC}"
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



