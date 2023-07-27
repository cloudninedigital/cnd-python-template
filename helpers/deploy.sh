#!/usr/bin/env bash

# Script options
set -e # exit immediately if a command exits with a non-zero status

# implement help option
usage() { echo "Usage: $0 -a action -s <stage> [-y]" 1>&2; exit 1; }

# Default values
auto_approve_option=""

# Parse options
while getopts ":a:s:y" o; do
    case "${o}" in
        a)
            action=${OPTARG}
            ;;
        s)
            stage=${OPTARG}
            ;;
        y)
            auto_approve_option="-auto-approve"
            ;;
        *)
            usage
            ;;
    esac
done

# Check if terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found."
    exit 1
fi

# Check action argument
if [ -z "${action}" ] || [ "${action}" != "plan" ] && [ "${action}" != "apply" ] && [ "${action}" != "validate" ]
then
    echo "Please provide either plan or apply as first argument."
    exit 1
fi

# Check stage argument
if [ -z "${stage}" ]
then
    echo "Please provide a stage as first argument."
    # print available stages
    echo "Available stages:"
    terraform -chdir="terraform" workspace list
    exit 1
fi

# Check if stage is valid with a terraform workspace
terraform -chdir="terraform" workspace select "${stage}"
if [ $? -ne 0 ]
then
    echo "Stage ${stage} is not a valid terraform workspace."
    # print available stages
    echo "Available stages:"
    terraform -chdir="terraform" workspace list
    exit 1
fi

# Check that variables file exists
if [ ! -f "terraform/${stage}.tfvars" ]
then
    echo "Variables file terraform/${stage}.tfvars does not exist."
    exit 1
fi

input_option=""
if [ "${action}" == "apply" ] || [ "${action}" == "plan" ]
then
    input_option="-input=true"
fi

# perform terraform action
terraform -chdir="terraform" "${action}" "$input_option" -var-file="${stage}.tfvars" ${auto_approve_option}

