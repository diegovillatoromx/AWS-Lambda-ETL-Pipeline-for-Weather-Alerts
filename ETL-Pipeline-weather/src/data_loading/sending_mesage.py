import os
import json
import boto3  
import pandas as pd
from twilio.rest import Client 

def lambda_handler(event, context):
    # Load environment variables
    account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
    auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
    phone_number = os.environ.get('PHONE_NUMBER')
    destination_number = '+573222007879'  # Define the destination number

    # Set up S3 client
    s3 = boto3.client('s3')
    source_bucket = 'transformed-data-weather-useast1-apiweather'

    # Assuming the event has the name of the file to process
    file_to_process = event['Records'][0]['s3']['object']['key']

    # Get the object from S3
    file_obj = s3.get_object(Bucket=source_bucket, Key=file_to_process)
    file_content = file_obj['Body'].read().decode('utf-8')

    # Convert content to DataFrame
    df = pd.read_csv(file_content)

    # Connect to Twilio
    client = Client(account_sid, auth_token)

    # Construct the message body
    input_date = file_to_process.split('.')[0]  # Assuming the file name is the date or contains it
    message_body = f"\nHello! \n\nThe weather forecast today {input_date} is:\n\n{str(df)}"

    # Send the message
    message = client.messages.create(
                        body=message_body,
                        from_=phone_number,
                        to=destination_number)

    return {
        'statusCode': 200,
        'body': json.dumps(f'Message sent successfully! Message SID: {message.sid}')
    }
