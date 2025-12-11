# Complete Setup Instructions for Signed Release APK

## ✅ Already Done

1. **build.gradle configured** - Signing configuration added
2. **key.properties template created** - Ready for your credentials

## 📋 What You Need to Do

### Step 1: Generate Keystore (5 minutes)

Open a **new PowerShell or Command Prompt** window and run:

```bash
keytool -genkey -v -keystore C:\Users\Lenovo\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Answer the prompts:**
- **Password:** Choose a strong password (write it down!)
- **Name, Organization, etc.:** Fill in or press Enter to skip
- **Confirm (yes/no):** Type `yes`
- **Key password:** Press Enter to use same password

### Step 2: Create key.properties File

Create this file: `C:\Users\Lenovo\OneDrive\Desktop\CV APP with antigravity\flutter_cv_app\android\key.properties`

**File contents (replace with your actual values):**

```properties
storePassword=YOUR_PASSWORD_HERE
keyPassword=YOUR_PASSWORD_HERE
keyAlias=upload
storeFile=C:\\Users\\Lenovo\\upload-keystore.jks
```

> **Example:**
> ```properties
> storePassword=MySecurePass123!
> keyPassword=MySecurePass123!
> keyAlias=upload
> storeFile=C:\\Users\\Lenovo\\upload-keystore.jks
> ```

### Step 3: Build Release APK

Run this command in your Flutter project directory:

```bash
flutter build apk --release
```

**This will:**
- ✅ Reduce APK size from 109 MB to ~25-40 MB
- ✅ Enable code obfuscation and optimization
- ✅ Make the app much faster
- ✅ Create production-ready APK

### Step 4: Find Your APK

The optimized APK will be at:
```
build\app\outputs\flutter-apk\app-release.apk
```

---

## 🔒 Security Reminders

1. **Never commit `key.properties` or `upload-keystore.jks` to git** (already gitignored)
2. **Back up your keystore file** to a secure location
3. **Save your passwords** in a password manager

---

## ❓ Need Help?

Once you've created the keystore and key.properties file, let me know and I'll help you build the release APK!
