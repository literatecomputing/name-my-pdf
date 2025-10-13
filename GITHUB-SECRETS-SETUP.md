# GitHub Actions Secrets Setup for Apple Signing

To enable automatic code signing and notarization in GitHub Actions, you need to set up several secrets in your repository.

## Required Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

### 1. CERTIFICATE_BASE64
Your Developer ID Application certificate exported as base64.

**Steps to create:**
1. Open Keychain Access
2. Find your "Developer ID Application: Jay Pfaffman (B9YN7Q93P9)" certificate
3. Right-click → Export "Developer ID Application..."
4. Save as `.p12` file with a password
5. Convert to base64:
   ```bash
   base64 -i /path/to/certificate.p12 | pbcopy
   ```
6. Paste the base64 string as the secret value

### 2. P12_PASSWORD
The password you used when exporting the certificate in step 1.

### 3. NOTARIZATION_PASSWORD
An app-specific password for notarization.

**Steps to create:**
1. Go to [Apple ID Account Management](https://appleid.apple.com/account/manage)
2. Navigate to **Sign-In and Security** → **App-Specific Passwords**
3. Click **Generate Password**
4. Label it "NameMyPdf GitHub Actions"
5. Copy the generated password (format: xxxx-xxxx-xxxx-xxxx)
6. Paste it as the secret value

## Secrets Summary

| Secret Name | Description | Example Format |
|-------------|-------------|----------------|
| `CERTIFICATE_BASE64` | Base64 encoded .p12 certificate | `MIIKvQIBAzCCCnkGCSqGSIb3...` |
| `P12_PASSWORD` | Password for the .p12 certificate | `mySecretPassword123` |
| `NOTARIZATION_PASSWORD` | App-specific password for Apple ID | `abcd-efgh-ijkl-mnop` |

## Verification

After setting up secrets, you can test the workflow by:

1. **Manual trigger** (for testing):
   ```bash
   # Go to Actions tab in GitHub
   # Select "Build, Sign and Release NameMyPdf"
   # Click "Run workflow"
   # Set sign: true
   # Run it
   ```

2. **Tag-based release** (for production):
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

## Security Notes

✅ **Secrets are encrypted** - Only accessible during GitHub Actions runs  
✅ **Limited scope** - Certificate can only be used for your app  
✅ **Temporary keychain** - Created and destroyed for each build  
✅ **No plain text passwords** - Stored securely in GitHub  

## Troubleshooting

### Certificate Issues
- Make sure you export the **private key** with the certificate
- Verify the certificate is valid and not expired
- Check that the Team ID (B9YN7Q93P9) matches your Developer account

### Notarization Issues
- Ensure the app-specific password is correct
- Verify your Apple ID has the Developer Program membership
- Check that the Team ID matches your Developer account

### GitHub Actions Issues
- Check the Actions logs for detailed error messages
- Verify all three secrets are set correctly
- Make sure the secret names match exactly (case-sensitive)

## Local Testing

Before setting up GitHub Actions, test the signing process locally:

```bash
# 1. Build unsigned
./bin/make-app-unsigned

# 2. Set up notarization credentials locally
xcrun notarytool store-credentials "notarization-password" \
    --apple-id "jay@literatecomputing.com" \
    --team-id "B9YN7Q93P9"

# 3. Sign and notarize
./bin/sign-and-notarize
```

If local signing works, GitHub Actions should work too (assuming secrets are set up correctly).

## Benefits of Automated Signing

Once set up, every release will be:

🔒 **Code signed** - Verified by Apple  
📋 **Notarized** - Scanned for malware  
📎 **Stapled** - Works offline  
✅ **No warnings** - Users can install without security prompts  
🤖 **Automated** - No manual intervention needed  

This provides a professional distribution experience for your users!