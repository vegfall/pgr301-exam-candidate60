#Frank: I chose to create a new lambda function, using elements from generate_image.py but put it in the SAM blueprint for hello_world. 
#I added multiple exception/error handling for different issues that has/might occur.
import json
import boto3
import base64
import random
import os

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

MODEL_ID = "amazon.titan-image-generator-v1"
BUCKET_NAME = os.environ.get("BUCKET_NAME")

def lambda_handler(event, context):
    if event["httpMethod"] != "POST":
        return {
            "statusCode": 405,
            "body": json.dumps({"message": "Method now allowed..."})
        }
        
    try:
        body = json.loads(event["body"])
        prompt = body.get("prompt", None)
        
        if not prompt:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Bad request..."})
            }
            
    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid JSON in request body..."})
        }
        
    seed = random.randint(0, 2147483647)
    image_prefix = "60/"
    image_name = f"image_{seed}.png"
    
    native_request = {
        "taskType": "TEXT_IMAGE",
        "textToImageParams": {"text": prompt},
        "imageGenerationConfig": {
            "numberOfImages": 1,
            "quality": "standard",
            "cfgScale": 8.0,
            "height": 1024,
            "width": 1024,
            "seed": seed
        }
    }
    
    try:
        response = bedrock_client.invoke_model(
            modelId = MODEL_ID,
            body = json.dumps(native_request)
        )
        
        model_response = json.loads(response["body"].read())
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)
        
        s3_client.put_object(Bucket=BUCKET_NAME, Key=image_prefix+image_name, Body=image_data)
        
        return {
            "statusCode": 201,
            "body": json.dumps({
                "message": f"Image {image_name} successfully generated in {BUCKET_NAME}. :)",
                "s3_image_path": f"s3://{BUCKET_NAME}/{image_prefix}{image_name}"
            })
        }
        
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "A server error occured..."})
        }