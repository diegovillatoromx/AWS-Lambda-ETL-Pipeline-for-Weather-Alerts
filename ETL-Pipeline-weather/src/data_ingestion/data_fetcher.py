import json
import os
import requests
from datetime import datetime
import boto3

def get_date(): 
    return datetime.now().strftime("%Y-%m-%d")

def request_wapi(api_key, query):
    url_clima = f'http://api.weatherapi.com/v1/forecast.json?key={api_key}&q={query}&days=1&aqi=no&alerts=no'
    try:
        response = requests.get(url_clima).json()
    except Exception as e:
        print(e)
        return None  # Manejar la excepción adecuadamente
    return response

def lambda_handler(event, context):
    # Variables de entorno
    api_key = os.environ['API_KEY_WAPI']  # Asegúrate de establecer esta variable en la configuración de la función Lambda
    bucket_name = 'raw-data-weather-useast1-apiweather'

    query = 'Mexico'  # O modificar para pasar como parte del evento

    # Obtener datos de API Weather
    input_date = get_date()
    weather_data = request_wapi(api_key, query)
    
    # Verificar respuesta
    if weather_data:
        # Convertir los datos a JSON
        data_string = json.dumps(weather_data)

        # Crear una instancia del cliente S3 y enviar los datos al bucket S3
        s3 = boto3.client('s3')
        s3.put_object(Bucket=bucket_name, Key=f"weather_data_{input_date}.json", Body=data_string)
        return {
            'statusCode': 200,
            'body': json.dumps('Data extracted and stored successfully!')
        }
    else:
        return {
            'statusCode': 500,
            'body': json.dumps('Failed to fetch or process data')
        }
