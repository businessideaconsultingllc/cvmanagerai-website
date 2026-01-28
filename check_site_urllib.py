
import urllib.request

urls = ['https://cvmanagerai.com/ads.txt', 'https://www.cvmanagerai.com/ads.txt']

for url in urls:
    print(f"\nChecking {url}:")
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            print(f"Status Code: {response.getcode()}")
            print(f"Content-Type: {response.getheader('Content-Type')}")
            print(f"Content: {response.read().decode('utf-8')}")
    except Exception as e:
        print(f"Error: {e}")
