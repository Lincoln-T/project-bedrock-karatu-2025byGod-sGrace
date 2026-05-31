import json
import urllib.parse

def lambda_handler(event, context):
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        print(f"Image received: {key} from bucket: {bucket}")

    return {
        "statusCode": 200,
        "body": json.dumps("Image processed successfully")
    }
