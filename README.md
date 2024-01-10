# AWS Lambda ETL-Pipeline-for-Weather-Alerts  
    
This repository hosts a project for an ETL pipeline designed to extract, transform, and load weather data using AWS Lambda, aimed at delivering meteorological alerts through Twilio. The system periodically triggers, pulling data from reliable weather sources, transforming it for accurate insights, and loading it for real-time notification delivery to interested users. This serverless approach offers a scalable and efficient solution for weather monitoring and early warning, aiding individuals and organizations to stay informed and prepared for adverse weather conditions. Integration with CloudWatch ensures detailed logging of pipeline operations and facilitates monitoring and debugging of the system. This project is crucial for risk management and decision-making in weather-dependent activities, promoting safety and proactive planning.   
  
The significance of this project lies in its ability to provide real-time weather alerts efficiently and automatically. Utilizing AWS Lambda's serverless architecture minimizes costs and maintenance needs while maximizing scalability and reliability. Accurate and timely weather alerts are vital for a wide range of applications, from personal safety and event planning to agriculture, logistics, and beyond. This system empowers users to anticipate and respond better to weather conditions, reducing risks and making informed decisions based on precise, up-to-date data.  

## Table of Contents   
 
- [Description](#description)
- [Architecture](#architecture)
- [Dataset](#Dataset)
- [Methodology](#Methodology)
- [Modular Code Overview](#modular-code-overview)
- [Contribution](#contribution)
- [Contact](#contact)




## Modular Code Overview

In the ETL-Pipeline-Weather project, the codebase is organized into distinct modules, each serving a specific role in the overall ETL (Extraction, Transformation, Load) process. This modular approach enhances maintainability, scalability, and clarity. Below is an overview of each module:

```graphql
ETL-Pipeline-Weather/
├── src/
│   ├── data_ingestion/  # Extraction
│   │   └── data_fetcher.py  # Lambda script for data fetching
│   ├── data_transformation/  # Transformation
│   │   └── data_transformer.py  # Lambda script for data transformation
│   ├── data_loading/  # Load
│   │   └── send_message.py  # Lambda script to send messages and verify delivery
├── infrastructure/
│   ├── create_resources.sh  # Script to create both S3 buckets and IAM roles
├── config/
│   ├── iam_data_ingestion_role.json  # IAM role for data fetching Lambda
│   ├── iam_data_loading_role.json  # IAM role for data loading Lambda
│   ├── iam_data_transformation_role.json  # IAM role for data transformation Lambda
│   ├── iam_role_config.json  # General IAM role configuration
│   ├── lambda_extract_config.json  # Configuration for the data extraction Lambda function
│   ├── lambda_sending_config.json  # Configuration for the data sending Lambda function
│   ├── lambda_transform_config.json  # Configuration for the data transformation Lambda function
│   ├── s3_raw_data_bucket_config.json  # Configuration for raw data S3 bucket
│   ├── s3_transformed_data_bucket_config.json  # Configuration for transformed data S3 bucket
├── logs/
│   ├── cloudwatch_logs.md  # Placeholder for logs or log instructions
└── README.md
```

`src/`: This directory is the core of the ETL process, containing Python scripts categorized by their roles in the ETL pipeline.

`data_ingestion/`: The data_fetcher.py script resides here. Its primary function is to extract weather data from an external API and store it in the raw data S3 bucket (`'raw-data-weather-useast1-apiweather'`). This represents the Extraction phase of the ETL process.

`data_transformation/`: Contains the data_transformer.py script, which is responsible for transforming the raw data. It reads data from the raw data S3 bucket, processes it (e.g., filtering, cleaning, aggregating), and stores the transformed data in another S3 bucket (`'transformed-data-weather-useast1-apiweather'`). This is the Transformation phase.

`data_loading/`: Here, the send_message.py script is tasked with the Load phase. It retrieves the transformed data, possibly formats or summarizes it, and then sends it to a specified phone number using Twilio.

`infrastructure/`: This directory contains infrastructure-as-code scripts.

`create_resources.sh`: A shell script used for setting up necessary AWS resources like S3 buckets for storing data and IAM roles for securing access to AWS services.
config/: Stores configuration files in JSON format, offering a centralized and structured way to manage various settings.

Files like `iam_data_ingestion_role.json`, `lambda_extract_config.json`, and `s3_raw_data_bucket_config.json` define configurations for specific AWS resources such as IAM roles for Lambda functions and settings for S3 buckets.

`logs/`: A designated place for storing logs or instructions related to AWS CloudWatch, aiding in monitoring and debugging.

`README.md`: The main documentation file for the project, providing an overview, setup instructions, and other essential information.

