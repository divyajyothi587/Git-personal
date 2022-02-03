import os
from downloadData import data_downloader
from s3Uploader import s3_uploader

BUCKET_NAME = os.getenv('BUCKET_NAME')

def mycode():
    # download the data
    download = data_downloader()
    # upload the data to s3bucket
    uploaded = s3_uploader('index.html', BUCKET_NAME, 'index.html')


mycode()