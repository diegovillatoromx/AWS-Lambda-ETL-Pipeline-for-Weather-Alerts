import boto3
import json 
import pandas as pd
from datetime import datetime  

# Function to get the forecast for a specific time in the API response
def get_forecast(response, i):
    # ... (same logic as provided in get_forecast from utils.py)
    date = response['forecast']['forecastday'][0]['hour'][i]['time'].split()[0]
    hour = int(response['forecast']['forecastday'][0]['hour'][i]['time'].split()[1].split(':')[0])
    condition = response['forecast']['forecastday'][0]['hour'][i]['condition']['text']
    temperature = response['forecast']['forecastday'][0]['hour'][i]['temp_c']
    will_it_rain = response['forecast']['forecastday'][0]['hour'][i]['will_it_rain']
    chance_of_rain = response['forecast']['forecastday'][0]['hour'][i]['chance_of_rain']
    return date, hour, condition, temperature, will_it_rain, chance_of_rain

# Function to create a DataFrame from the data and filter based on rain conditions
def create_df(data):
    # ... (same logic as provided in create_df from utils.py)
    cols = ['Date', 'Hour', 'Condition', 'Temperature', 'Rain', 'ProbOfRain']
    df = pd.DataFrame(data, columns=cols)
    df = df.sort_values(by='Hour', ascending=True)
    rain_df = df[(df['Rain'] == 1) & (df['Hour'] > 6) & (df['Hour'] < 22)]
    rain_df = rain_df[['Hour', 'Condition']]
    rain_df.set_index('Hour', inplace=True)
    return rain_df

def lambda_handler(event, context):
    # ... (rest of the lambda_handler code that reads and writes from S3 buckets)
    source_bucket = 'raw-data-weather-useast1-apiweather'
    destination_bucket = 'transformed-data-weather-useast1-apiweather'
    
    file_to_process = event['Records'][0]['s3']['object']['key']
    
    s3 = boto3.client('s3')
    file_obj = s3.get_object(Bucket=source_bucket, Key=file_to_process)
    file_content = file_obj['Body'].read().decode('utf-8')
    response = json.loads(file_content)

    data = [get_forecast(response, i) for i in range(24)]
    transformed_df = create_df(data)
    transformed_data_string = transformed_df.to_csv()

    s3.put_object(Bucket=destination_bucket, Key=file_to_process, Body=transformed_data_string)

    return {
        'statusCode': 200,
        'body': json.dumps('Data transformed and stored successfully!')
    }
