import requests
import json

base_url = "http://127.0.0.1:8000"
query = "shape of you"

try:
    response = requests.get(f"{base_url}/search/suggestions?query={query}")
    print(f"Status Code: {response.statusCode}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Error: {e}")
