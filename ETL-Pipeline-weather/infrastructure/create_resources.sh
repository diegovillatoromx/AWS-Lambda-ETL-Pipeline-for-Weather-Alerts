#!/bin/bash

# Define the directory where the configurations are
CONFIG_DIR="../config" 

# Function to check if an S3 bucket exists
check_s3_bucket_exists() {
    if aws s3api head-bucket --bucket "$1" --region "$2" 2>/dev/null; then
        echo "Bucket $1 already exists."
        return 0
    else
        return 1 
    fi
}

# Function to check if an IAM role exists
check_iam_role_exists() {
    if aws iam get-role --role-name "$1" 2>/dev/null; then
        echo "Role $1 already exists."
        return 0
    else
        return 1
    fi
}

echo "Checking and Creating S3 Buckets..."
# List of S3 bucket configuration files
declare -a bucket_configs=("s3_raw_data_bucket_config.json" "s3_transformed_data_bucket_config.json")

# Loop through each S3 bucket configuration file and create the S3 bucket if it doesn't exist
for bucket_config in "${bucket_configs[@]}"
do
    bucket_name=$(cat "${CONFIG_DIR}/${bucket_config}" | jq -r '.BucketName')
    bucket_region=$(cat "${CONFIG_DIR}/${bucket_config}" | jq -r '.Region')
    # Check if bucket exists
    if ! check_s3_bucket_exists "$bucket_name" "$bucket_region"; then
        # Create the S3 bucket using the AWS CLI
        aws s3api create-bucket --bucket "$bucket_name" --region "$bucket_region" --create-bucket-configuration LocationConstraint="$bucket_region"
        echo "Created bucket: $bucket_name in region: $bucket_region"
    fi
done

echo "Checking and Creating IAM Roles for Lambda Functions..."
# List of IAM role configuration files
declare -a role_configs=("iam_data_ingestion_role.json" "iam_data_loading_role.json" "iam_data_transformation_role.json")

# Loop through each IAM role configuration file and create the IAM role if it doesn't exist
for role_config in "${role_configs[@]}"
do
    role_name=$(cat "${CONFIG_DIR}/${role_config}" | jq -r '.RoleName')
    # Check if role exists
    if ! check_iam_role_exists "$role_name"; then
        trust_policy=$(cat "${CONFIG_DIR}/${role_config}" | jq -r '.PolicyDocument | tostring')
        # Create the IAM role using the AWS CLI
        created_role=$(aws iam create-role --role-name "$role_name" --assume-role-policy-document "$trust_policy")
        echo "Created IAM Role: $role_name"
        # Extract the role ARN from the created role
        role_arn=$(echo $created_role | jq -r '.Role.Arn')
        # Attach policies to the role
        for policy_arn in $(cat "${CONFIG_DIR}/${role_config}" | jq -r '.Policies[]')
        do
            aws iam attach-role-policy --role-name "$role_name" --policy-arn "$policy_arn"
            echo "Attached policy $policy_arn to $role_name"
        done
        echo "Created IAM Role for Lambda with ARN: $role_arn"
    fi
done

echo "Starting the creation of the Lambda function for data extraction..."

# Load the configuration directory and file name from lambda_config.json
CONFIG_FILE="lambda_config.json"
CONFIG_DIR=$(jq -r '.ConfigDir' < "$CONFIG_FILE")

# Load the Lambda function configuration from the .json file
LAMBDA_DIR=$(jq -r '.LambdaDir' < "${CONFIG_DIR}/${CONFIG_FILE}")
ZIP_FILE=$(jq -r '.ZipFile' < "${CONFIG_DIR}/${CONFIG_FILE}")
FUNCTION_NAME=$(jq -r '.FunctionName' < "${CONFIG_DIR}/${CONFIG_FILE}")
ROLE=$(jq -r '.Role' < "${CONFIG_DIR}/${CONFIG_FILE}")
HANDLER=$(jq -r '.Handler' < "${CONFIG_DIR}/${CONFIG_FILE}")
RUNTIME=$(jq -r '.Runtime' < "${CONFIG_DIR}/${CONFIG_FILE}")
DESCRIPTION=$(jq -r '.Description' < "${CONFIG_DIR}/${CONFIG_FILE}")
TIMEOUT=$(jq -r '.Timeout' < "${CONFIG_DIR}/${CONFIG_FILE}")
MEMORY_SIZE=$(jq -r '.MemorySize' < "${CONFIG_DIR}/${CONFIG_FILE}")
ENVIRONMENT=$(jq -r '.Environment' < "${CONFIG_DIR}/${CONFIG_FILE}" | jq -c .)

# Function to check if the Lambda function already exists
check_lambda_exists() {
    if aws lambda get-function --function-name "$1" 2>/dev/null; then
        echo "The Lambda function $1 already exists."
        return 0
    else
        return 1
    fi
}

echo "Preparing the deployment package..."

# Changing to the Lambda function directory and creating the ZIP file
cd "$LAMBDA_DIR"
if [ ! -f "../${ZIP_FILE}" ]; then
    zip -r9 "../${ZIP_FILE}" "data_fetcher.py"
    echo "Created ZIP file: ${ZIP_FILE}"
else
    echo "ZIP file ${ZIP_FILE} already exists."
fi

# Returning to the original directory
cd -

# Check if the Lambda function already exists
if ! check_lambda_exists "$FUNCTION_NAME"; then

    # Using AWS CLI to create the Lambda function
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime "$RUNTIME" \
        --role "$ROLE" \
        --handler "$HANDLER" \
        --description "$DESCRIPTION" \
        --timeout "$TIMEOUT" \
        --memory-size "$MEMORY_SIZE" \
        --environment "$ENVIRONMENT" \
        --zip-file "fileb://${ZIP_FILE}"

    echo "Lambda function $FUNCTION_NAME created successfully."
else
    echo "Moving on, $FUNCTION_NAME Lambda function already exists."
fi

echo "Starting the creation of the Lambda function for data transformation..."

# Load the configuration from lambda_config.json
CONFIG_FILE="lambda_config.json"

# Load the Lambda function configuration from the .json file
LAMBDA_DIR=$(jq -r '.LambdaDir' < "$CONFIG_FILE")
ZIP_FILE=$(jq -r '.ZipFile' < "$CONFIG_FILE")
FUNCTION_NAME=$(jq -r '.FunctionName' < "$CONFIG_FILE")
# ... (rest of the configuration)

ROOT_DIR=$(pwd) # Save the current directory

echo "Preparing the deployment package..."

# Changing to the Lambda function directory and creating the ZIP file
cd "$LAMBDA_DIR"
if [ ! -f "../${ZIP_FILE}" ]; then
    zip -r9 "../${ZIP_FILE}" "data_transformer.py"
    echo "Created ZIP file: ${ZIP_FILE}"
else
    echo "ZIP file ${ZIP_FILE} already exists."
fi

# Returning to the original directory
cd "$ROOT_DIR"

# Check if the Lambda function already exists
if aws lambda get-function --function-name "$FUNCTION_NAME" 2>/dev/null; then
    echo "The Lambda function $FUNCTION_NAME already exists."
else
    # If function does not exist, create it with the specified configurations
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime "$RUNTIME" \
        --role "$ROLE" \
        --handler "$HANDLER" \
        --description "$DESCRIPTION" \
        --timeout "$TIMEOUT" \
        --memory-size "$MEMORY_SIZE" \
        --environment "$ENVIRONMENT" \
        --layers "$LAYERS" \
        --zip-file "fileb://${ZIP_FILE}"

    echo "Lambda function $FUNCTION_NAME created successfully."
fi



echo "Starting the creation of the Lambda function for sending weather updates..."

# Load the configuration from lambda_config.json
CONFIG_FILE="lambda_config.json"

# Load the Lambda function configuration from the .json file
LAMBDA_DIR=$(jq -r '.LambdaDir' < "$CONFIG_FILE")
ZIP_FILE=$(jq -r '.ZipFile' < "$CONFIG_FILE")
FUNCTION_NAME=$(jq -r '.FunctionName' < "$CONFIG_FILE")
# ... (rest of the configuration)

ROOT_DIR=$(pwd) # Save the current directory

echo "Preparing the deployment package..."

# Changing to the Lambda function directory and creating the ZIP file
cd "$LAMBDA_DIR"
if [ ! -f "../${ZIP_FILE}" ]; then
    echo "Creating ZIP file: ${ZIP_FILE}..."
    zip -r9 "../${ZIP_FILE}" "send_message.py"
    echo "Created ZIP file: ${ZIP_FILE}"
else
    echo "ZIP file ${ZIP_FILE} already exists."
fi

# Returning to the original directory
cd "$ROOT_DIR"

# Check if the Lambda function already exists
if aws lambda get-function --function-name "$FUNCTION_NAME" 2>/dev/null; then
    echo "The Lambda function $FUNCTION_NAME already exists. Moving to update."
    # Update the function code if it already exists (you might want to update other configurations too)
    aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://${ZIP_FILE}"
    echo "Lambda function $FUNCTION_NAME updated successfully."
else
    # If function does not exist, create it with the specified configurations
    ROLE=$(jq -r '.Role' < "$CONFIG_FILE")
    HANDLER=$(jq -r '.Handler' < "$CONFIG_FILE")
    RUNTIME=$(jq -r '.Runtime' < "$CONFIG_FILE")
    DESCRIPTION=$(jq -r '.Description' < "$CONFIG_FILE")
    TIMEOUT=$(jq -r '.Timeout' < "$CONFIG_FILE")
    MEMORY_SIZE=$(jq -r '.MemorySize' < "$CONFIG_FILE")
    ENVIRONMENT=$(jq -r '.Environment' < "$CONFIG_FILE" | jq -c .)
    LAYERS=$(jq -r '.Layers' < "$CONFIG_FILE")

    echo "Creating new Lambda function $FUNCTION_NAME..."
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime "$RUNTIME" \
        --role "$ROLE" \
        --handler "$HANDLER" \
        --description "$DESCRIPTION" \
        --timeout "$TIMEOUT" \
        --memory-size "$MEMORY_SIZE" \
        --environment "$ENVIRONMENT" \
        --layers "$LAYERS" \
        --zip-file "fileb://${ZIP_FILE}"

    echo "Lambda function $FUNCTION_NAME created successfully."
fi
