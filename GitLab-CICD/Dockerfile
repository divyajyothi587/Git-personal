FROM python:3.8.0-alpine
RUN pip install requests boto3
COPY downloadData.py s3Uploader.py code.py /code/
WORKDIR /code/
ENTRYPOINT [ "python code.py" ]