# Quick Password Update Guide

## ✅ What's Done
- Keystore created: `C:\Users\Lenovo\upload-keystore.jks`
- `android\key.properties` file created with placeholders

## 📝 What You Need To Do

Update the password in `android\key.properties`. Choose **ONE** method:

### Method 1: PowerShell Command (Quick)

Run this in PowerShell (replace `YOUR_ACTUAL_PASSWORD` with your keystore password):

```powershell
(Get-Content android\key.properties) -replace 'YOUR_PASSWORD_HERE', 'YOUR_ACTUAL_PASSWORD' | Set-Content android\key.properties
```

**Example:** If your password is `MyPass123`:
```powershell
(Get-Content android\key.properties) -replace 'YOUR_PASSWORD_HERE', 'MyPass123' | Set-Content android\key.properties
```

### Method 2: Manual Edit

1. Open `android\key.properties` in any text editor
2. Replace both `YOUR_PASSWORD_HERE` with your actual password
3. Save the file

The file should look like:
```properties
storePassword=YOUR_ACTUAL_PASSWORD
keyPassword=YOUR_ACTUAL_PASSWORD
keyAlias=upload
storeFile=C:\\Users\\Lenovo\\upload-keystore.jks
```

## ▶️ Next Step

After updating the password, let me know and I'll run:
```bash
flutter build apk --release
```

This will create your optimized ~25-40 MB APK!
