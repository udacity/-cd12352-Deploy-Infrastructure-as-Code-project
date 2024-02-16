#!/bin/bash
# This script expects the following variables
# REGION as an environment variable
# AWS CLI configurated

#!/bin/bash

# Default values
STACKNAME="$STACKNAME"
TEMPLATE="$TEMPLATE"
PARAMETERS="$PARAMETERS"

# Function to display usage instructions
usage() {
    echo "Usage: $0 [--stackname <stackname>] [--template <template>] [--parameters <parameters>]"
    echo "       $0 <stackname> <template> <parameters>"
    exit 1
}

# Check if the number of arguments is correct
if [ $# -ne 3 ]; then
    # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
      key="$1"
      case $key in
          --stackname)
              STACKNAME="$2"
              shift 2
              ;;
          --template)
              TEMPLATE="$2"
              shift 2
              ;;
          --parameters)
              PARAMETERS="$2"
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
if [[ -z $STACKNAME || -z $TEMPLATE || -z $PARAMETERS ]]; then
    usage
fi

echo "Stackname: $STACKNAME"
echo "Template: $TEMPLATE"
echo "Parameters: $PARAMETERS"


echo "Start check if stackname $STACKNAME  exists in region $REGION"

if ! aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACKNAME" > /dev/null 2>&1 ; then


  echo -e "\nStack does not exist, creating ..."
  aws cloudformation create-stack \
  --stack-name "$STACKNAME" \
  --template-body "file://$TEMPLATE" \
  --parameters="file://network/network-parameters.json" \
  --region=$REGION   
  
  echo "Waiting for stack to be created ..."
  aws cloudformation wait stack-create-complete --stack-name $STACKNAME --region=$REGION

else

  echo -e "\nStack exists, attempting update ..."

# This script temporarily disables automatic script termination
# executes an AWS CLI command to update a CloudFormation stack
# captures the output (including any error messages)
# stores the exit status of the AWS CLI command
# and then re-enables automatic script termination.

  set +e
  update_output=$( aws cloudformation update-stack \
    --stack-name $STACKNAME \
    --template-body file://$TEMPLATE \
    --parameters file://$PARAMETERS \
    --region=$REGION 2>&1)
  
  status=$?
  set -e

  echo "$update_output"


# handling the case where an update operation is attempted but no changes are needed.
# If the update output contains both "ValidationError" and "No updates", it exits with a success status code.
# Otherwise, it exits with the status code indicating the failure.

  if [ $status -ne 0 ] ; then
    if [[ $update_output == *"ValidationError"* && $update_output == *"No updates"* ]] ; then
      echo -e "\nFinished create or update - no updates to be performed"
      exit 0
    else
      exit $status
    fi
  fi
  
  echo "Waiting for stack creation or update "
  aws cloudformation wait stack-update-complete --stack-name $STACKNAME --region=$REGION

fi

echo "Finished creating or updating stack successfully!"