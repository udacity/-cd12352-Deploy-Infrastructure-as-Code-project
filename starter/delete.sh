#!/bin/bash
# This script expects the following variables
# REGION as an environment variable
# AWS CLI configurated

STACKNAME="$STACKNAME"

# Function to display usage instructions
usage() {
    echo "Usage: $0 [--stackname <stackname>]"
    echo "       $0 <stackname>"
    exit 1
}

# Check if the number of arguments is correct
if [ $# -ne 1 ]; then
    # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
      key="$1"
      case $key in
          --stackname)
              STACKNAME="$2"
              shift 2
              ;;
          *)
              # If an invalid flag is provided or positional parameters are used, display usage instructions
              usage
              ;;
      esac
  done
fi

# If any required parameter is missing, display usage instructions
if [[ -z $STACKNAME  ]]; then
    usage
fi

echo "Stackname: $STACKNAME"

echo "Start check if stackname {$STACKNAME}  exists in region {$REGION}"

if aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACKNAME" > /dev/null 2>&1 ; then
  echo -e "\nStack exists, deleting ..."
  delete_output=$(aws cloudformation delete-stack --stack-name "$STACKNAME" 2>&1)
  delete_status=$?
  if [ $delete_status -eq 0 ]; then
    echo "Deletion request sent successfully. Waiting for stack to be deleted ..."
    aws cloudformation wait stack-delete-complete --stack-name "$STACKNAME" --region "$REGION"
    echo "Stack deletion successful."
  else
    echo "Failed to delete stack. Error message: $delete_output"
    exit 1
  fi
fi
