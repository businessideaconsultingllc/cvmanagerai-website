
import requests

url = 'https://cvmanagerai.com/ads.txt'
try:
    response = requests.get(url, timeout=10)
    print(f"Status Code: {response.status_code}")
    print(f"Content-Type: {response.headers.get('Content-Type')}")
    print(f"Content: {response.text}")
except Exception as e:
    print(f"Error: {e}")

url_www = 'https://www.cvmanagerai.com/ads.txt'
try:
    response = requests.get(url_www, timeout=10)
    print(f"\nWWW Status Code: {response.status_code}")
    print(f"WWW Content-Type: {response.headers.get('WWW Content-Type')}") # Content-Type
    print(f"WWW Content-Type: {response.headers.get('Content-Type')}")
except Exception as e:
    print(f"Error: {e}")
