import json

# Read the current ARB file
with open(r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb\app_en.arb', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Add/fix the missing keys
data["skip"] = "Skip"
data["@skip"] = {
    "description": "Skip button text"
}

data["getStarted"] = "Get Started"
data["@getStarted"] = {
    "description": "Get started button text"
}

data["alreadyHaveAccount"] = "Already have an account?"
data["@alreadyHaveAccount"] = {
    "description": "Already have account text"
}

data["logIn"] = "Log In"
data["@logIn"] = {
    "description": "Log in link text"
}

data["aiPoweredResumeCreation"] = "AI-Powered\nResume Creation"
data["@aiPoweredResumeCreation"] = {
    "description": "Onboarding title"
}

data["onboardingDescription"] = "Create professional, ATS-friendly resumes in seconds using our advanced AI technology."
data["@onboardingDescription"] = {
    "description": "Onboarding description"
}

data["selectLanguage"] = "Select Language"
data["@selectLanguage"] = {
    "description": "Select language title"
}

# Write back with proper formatting
with open(r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb\app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print("Successfully fixed app_en.arb with correct onboarding strings")
