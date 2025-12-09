# Keystore Setup Guide for CV App Release

## Step 1: Generate Keystore

Open PowerShell (or Command Prompt) and run this command:

```bash
keytool -genkey -v -keystore C:\Users\Lenovo\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## Step 2: Answer the Interactive Questions

The keytool will ask you several questions. Here are recommended answers:

1. **Enter keystore password:** Choose a strong password (e.g., `CVApp2024!Secure`) - **WRITE THIS DOWN!**
2. **Re-enter new password:** Enter the same password again
3. **What is your first and last name?** Your name or organization name
4. **What is the name of your organizational unit?** (e.g., `Development` or just press Enter)
5. **What is the name of your organization?** (e.g., `CV Manager AI` or just press Enter)
6. **What is the name of your City or Locality?** Your city or press Enter
7. **What is the name of your State or Province?** Your state or press Enter
8. **What is the two-letter country code?** (e.g., `US`, `UK`, etc. or press Enter)
9. **Is CN=..., correct?** Type `yes` and press Enter
10. **Enter key password for <upload>:** Press Enter to use the same password as keystore

## Step 3: Note Your Credentials

After generation, **save these details securely**:

- **Keystore path:** `C:\Users\Lenovo\upload-keystore.jks`
- **Keystore password:** [the password you chose in step 1]
- **Key alias:** `upload`
- **Key password:** [same as keystore password]

## Step 4: Continue

Once you've successfully created the keystore, let me know and I'll configure your Flutter project to use it!

---

> [!IMPORTANT]
> **Keep your keystore file and passwords safe!**
> - Back up the `.jks` file to a secure location
> - Never commit it to git
> - If you lose it, you won't be able to update your app on the Play Store
