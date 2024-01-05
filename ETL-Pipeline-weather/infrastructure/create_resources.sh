#!/bin/bash

# Define the directory where the configurations are
CONFIG_DIR="../config"

echo "Creating S3 Buckets..."
# Loop through each S3 bucket configuration file and create the S3 bucket
for bucket_config in "s3_raw_data_bucket_config.json" "s3_transformed_data_bucket_config.json" "s3_load_data_bucket_config.json"
do
    bucket_name=$(cat "${CONFIG_DIR}/${bucket_config}" | jq -r '.BucketName')
    aws s3api create-bucket --bucket $bucket_name --region us-east-1
    echo "Created bucket: $bucket_name"
done

echo "Creating IAM Roles..."
# Loop through each IAM role configuration file and create the IAM role
for role_config in "iam_data_ingestion_role.json" "iam_data_transformation_role.json" "iam_data_loading_role.json"
do
    role_name=$(cat "${CONFIG_DIR}/${role_config}" | jq -r '.RoleName')
    trust_policy="{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Principal\": {\"Service\": \"lambda.amazonaws.com\"},\"Action\": \"sts:AssumeRole\"}]}"
    aws iam create-role --role-name "$role_name" --assume-role-policy-document "$trust_policy"
    # Attach policies or handle inline policies as needed here...
    echo "Created role: $role_name"
done

# Additional commands or configurations can be added here for each resource as needed
