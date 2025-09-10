import boto3
import json
import os
from decimal import Decimal

comprehend = boto3.client('comprehend')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def convert_floats(obj):
    if isinstance(obj, list):
        return [convert_floats(i) for i in obj]
    elif isinstance(obj, dict):
        return {k: convert_floats(v) for k, v in obj.items()}
    elif isinstance(obj, float):
        return Decimal(str(obj))
    else:
        return obj

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        s3 = boto3.client('s3')
        file_obj = s3.get_object(Bucket=bucket, Key=key)
        text = file_obj['Body'].read().decode('utf-8', errors='ignore')

        sentiment = comprehend.detect_sentiment(Text=text, LanguageCode='en')
        entities = comprehend.detect_entities(Text=text, LanguageCode='en')

        table.put_item(Item={
            'file_name': key,
            'sentiment': convert_floats(sentiment),
            'entities': convert_floats(entities['Entities'])
        })

    return {"status": "ok"}
