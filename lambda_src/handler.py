import json
import base64
import boto3
import os
from decimal import Decimal

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])
comprehend = boto3.client('comprehend')

# Define CORS headers
CORS_HEADERS = {
    "Access-Control-Allow-Origin": "http://localhost:3000",
    "Access-Control-Allow-Headers": "Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
}

def lambda_handler(event, context):
    # Handle CORS preflight request
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": ""
        }

    try:
        body = json.loads(event.get('body', '{}'))
        file_content = base64.b64decode(body['file_content'])
        file_name = body['file_name']

        # Upload to S3
        bucket_name = os.environ['UPLOAD_BUCKET']
        s3.put_object(Bucket=bucket_name, Key=file_name, Body=file_content)

        # Decode text safely
        text = file_content.decode('utf-8', errors='ignore')

        # Analyze sentiment and entities
        sentiment = comprehend.detect_sentiment(Text=text, LanguageCode='en')
        entities = comprehend.detect_entities(Text=text, LanguageCode='en')

        # Convert floats to Decimal for DynamoDB
        def convert_floats(obj):
            if isinstance(obj, list):
                return [convert_floats(i) for i in obj]
            elif isinstance(obj, dict):
                return {k: convert_floats(v) for k, v in obj.items()}
            elif isinstance(obj, float):
                return Decimal(str(obj))
            else:
                return obj

        table.put_item(Item={
            'file_name': file_name,
            'sentiment': convert_floats(sentiment),
            'entities': convert_floats(entities['Entities'])
        })

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({
                "message": "File uploaded and analyzed!",
                "sentiment": sentiment,
                "entities": entities['Entities']
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }
