import json

# Read the current ARB file
with open(r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb\app_en.arb', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Add new localization keys for profile and navigation
new_keys = {
    "myFiles": "My Files",
    "@myFiles": {
        "description": "My Files navigation label"
    },
    "myFilesDescription": "View all documents",
    "@myFilesDescription": {
        "description": "My Files description"
    },
    "profile": "Profile",
    "@profile": {
        "description": "Profile navigation label"
    },
    "profileDescription": "Manage your info",
    "@profileDescription": {
        "description": "Profile description"
    },
    "editProfile": "Edit Profile",
    "@editProfile": {
        "description": "Edit profile button text"
    },
    "saveChanges": "Save Changes",
    "@saveChanges": {
        "description": "Save changes button text"
    },
    "profileUpdatedSuccessfully": "Profile updated successfully",
    "@profileUpdatedSuccessfully": {
        "description": "Profile update success message"
    },
    "phoneNumber": "Phone Number",
    "@phoneNumber": {
        "description": "Phone number label"
    },
    "fullName": "Full Name",
    "@fullName": {
        "description": "Full name label"
    },
    "viewProfile": "View Profile",
    "@viewProfile": {
        "description": "View profile button text"
    },
    "personalInformation": "Personal Information",
    "@personalInformation": {
        "description": "Personal information section title"
    }
}

# Add all new keys to the data
data.update(new_keys)

# Write back with proper formatting
with open(r'c:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\lib\l10n\arb\app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print("Successfully added profile and navigation localization strings")
