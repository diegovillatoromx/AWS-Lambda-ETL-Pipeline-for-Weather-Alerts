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

# (Additional commands or configurations can be added here for each resource as needed)
