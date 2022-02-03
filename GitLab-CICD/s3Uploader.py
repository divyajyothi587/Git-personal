import boto3
import os
from botocore.exceptions import NoCredentialsError

AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')

def s3_uploader(local_file, s3_bucket, s3_file):
    s3 = boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY_ID,
                      aws_secret_access_key=AWS_SECRET_ACCESS_KEY)

    try:
        s3.upload_file(local_file, s3_bucket, s3_file, ExtraArgs={'ContentType': "text/html"})
        print("Upload Successful")
        return True
    except FileNotFoundError:
        print("The file is missing...!, Task aborting...!")
    except NoCredentialsError:
        print("Credentials not available...!,  Task aborting...!")
