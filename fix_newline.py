import json

# Read the currentARB file
with open(r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb\app_en.arb', 'r', encoding='utf-8') as f:
    content = f.read()

# Simple text replacement to fix the newline
content = content.replace('"aiPoweredResumeCreation": "AI-Powered\\\\nResume Creation"', '"aiPoweredResumeCreation": "AI-Powered\\nResume Creation"')

# Write back
with open(r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb\app_en.arb', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed AI-Powered newline")
