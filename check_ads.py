
import os

file_path = r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\ads.txt'

with open(file_path, 'rb') as f:
    content = f.read()
    print(f"Content: {content}")
    print(f"Hex: {content.hex(' ')}")
