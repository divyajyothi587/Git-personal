import requests
import os

WEATHER_API_KEY = os.getenv('WEATHER_API_KEY')
CITY_ID = os.getenv('CITY_ID')
# 3077311 - Czechia
# 3067696 - Prague

def data_downloader():
    url = "https://api.openweathermap.org/data/2.5/weather"
    params = {'id':CITY_ID,
            'appid':WEATHER_API_KEY,
            'mode':'html'}
    r = requests.get(url, params=params)
    with open("index.html",'wb') as f:
            f.write(r.content)