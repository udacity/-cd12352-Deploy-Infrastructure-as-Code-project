## Make sure the REGION and NETWORKSTACKNAME and SERVERSTACKNAME environment variables are filled
region=0
stacknamespace=0
stackenv=0

if [ -z "$REGION" ]; then
    echo "REGION environment variable is not provided."
    region=1
fi
if [ -z "$STACKNAMESPACE" ]; then
    echo "STACKNAMESPACE environment variable is not provided."
    stacknamespace=1
fi
if [ -z "$STACKENV" ]; then
    echo "STACKENV environment variable is not provided."
    stackenv=1
fi

envvars=$((region || stacknamespace || stackenv ))
if [ $envvars -eq 1 ]; then
  echo "Set your environment variables before continuing"
else
  echo "Environment variables are set correctly."
  NETWORKSTACKNAME=$(echo "$STACKNAMESPACE-$STACKENV-NETWORK" | tr '[:upper:]' '[:lower:]')
  echo "Network stackname = $NETWORKSTACKNAME"
fi


# Loop through the command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --profile)
            # If --profile is found, capture the next argument as the profile name
            PROFILE="$2"
            shift  # Move to the next argument
            ;;
        *)
            # Ignore other arguments
            ;;
    esac
    shift  # Move to the next argument
done

cli=0
config=0
creds=0

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it and configure your credentials."
    cli=1
fi

# Check if AWS CLI configuration exists
if ! aws configure get aws_access_key_id  &> /dev/null; then
    echo "AWS CLI configuration is missing. Please run 'aws configure' to set up your credentials."
    config=1
fi

# Check if the configured credentials are valid
aws sts get-caller-identity &> /dev/null
if [ $? -ne 0 ]; then
    echo "AWS CLI configuration is incorrect. Please verify your credentials."
    creds=1
fi

awsvars=$((cli || config ||creds))

if [ $awsvars -eq 1 ];  then
  echo "Please verify your AWS configuration."
else
  echo "AWS CLI configuration is correct."
fi

if [ $awsvars -eq 1 ]; then
  exit 1
fi
if [ $awsvars -eq 1 ]; then
  exit 1
fi