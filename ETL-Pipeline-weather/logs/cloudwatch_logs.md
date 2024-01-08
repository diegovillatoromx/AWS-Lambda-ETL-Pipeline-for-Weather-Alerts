
# CloudWatch Logs for ETL-Pipeline-Weather

## Overview

AWS CloudWatch Logs provide invaluable insights into the operation and performance of the AWS Lambda functions in the `ETL-Pipeline-Weather` project. This document serves as a guide to accessing, understanding, and utilizing these logs for monitoring and troubleshooting.

## Accessing Logs

To access the logs for a specific Lambda function:

1. Open the AWS Management Console.
2. Go to the CloudWatch service.
3. In the navigation pane, choose 'Logs' and then 'Log groups'.
4. Find and select the log group for your Lambda function. Log groups typically follow the format `/aws/lambda/<function-name>`.

## Reading Logs

Each log stream within a group corresponds to a Lambda function invocation. Key things to look for:

- **Start Time**: Indicates when the Lambda function was triggered.
- **Duration**: Shows how long the function execution took.
- **Memory Usage**: Displays the amount of memory used by the function.
- **Error Messages**: Critical for troubleshooting. Look for exceptions or error keywords.

## Common Issues and Troubleshooting

- **Timeouts**: If the function times out, consider increasing the timeout setting in your Lambda function configuration.
- **Memory Issues**: If your function is running out of memory, you may need to increase the allocated memory in the function's configuration.
- **Execution Errors**: Look for stack traces or error messages in the log stream to understand the root cause.

## Best Practices

- Regularly monitor your CloudWatch logs to preemptively identify and resolve issues.
- Set up CloudWatch Alarms to get alerted on errors or specific conditions.
- Utilize log filtering and metric extraction features in CloudWatch to focus on important log data.

## Additional Resources

- [AWS CloudWatch Logs User Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)
- [AWS Lambda Developer Guide – Monitoring and Troubleshooting](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-troubleshooting.html)

Remember, logs are crucial for understanding the behavior and health of your Lambda functions. Regular monitoring and review are key to maintaining a robust ETL pipeline.
