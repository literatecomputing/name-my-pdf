# Apple Code Signing & Notarization Setup Guide

This guide will help you set up modern Apple code signing and notarization for NameMyPdf using the current tools and best practices.

## Prerequisites

You'll need:

1. **Apple Developer Account** (paid, $99/year)
2. **Developer ID Application certificate** installed in Keychain
3. **Xcode Command Line Tools** installed
4. **App-specific password** for notarization

## Step 1: Install Certificates

### Check Current Certificates
```bash
# List all Developer certificates in Keychain
security find-identity -v -p codesigning

# Look for something like:
# "Developer ID Application: Jay Pfaffman (B9YN7Q93P9)"
```

### If You Don't Have Certificates

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/)
2. Create a new **Developer ID Application** certificate
3. Download and double-click to install in Keychain Access

## Step 2: Create App-Specific Password

1. Go to [Apple ID Account Management](https://appleid.apple.com/account/manage)
2. Navigate to **Sign-In and Security** → **App-Specific Passwords**
3. Click **Generate Password**
4. Label it "NameMyPdf Notarization"
5. **Save the generated password** - you'll need it in the next step

## Step 3: Store Notarization Credentials

Run this command to securely store your credentials:

```bash
xcrun notarytool store-credentials "notarization-password" \
    --apple-id "jay@literatecomputing.com" \
    --team-id "B9YN7Q93P9"
```

When prompted:
- Enter the **app-specific password** you created in Step 2
- This stores credentials securely in your Keychain

## Step 4: Verify Setup

```bash
# Test that notarytool can access your credentials
xcrun notarytool history --keychain-profile "notarization-password"
```

You should see a (possibly empty) list of previous submissions.

## Step 5: Build and Sign

Now you can use the updated workflow:

```bash
# 1. Build the app (unsigned)
./bin/make-app-unsigned

# 2. Sign and notarize
./bin/sign-and-notarize
```

## What the New Process Does

### Code Signing
- Signs the app bundle with **hardened runtime** (required for notarization)
- Signs the DMG file
- Uses timestamping for long-term validation

### Notarization
- Submits to Apple's notarization service using `notarytool` (replaces deprecated `altool`)
- Waits for Apple's automated security scan
- Retrieves the notarization ticket

### Stapling
- Attaches the notarization ticket to both app and DMG
- Enables offline verification (no internet required for users)

## Security Improvements

✅ **No passwords in scripts** - Stored securely in Keychain  
✅ **Modern notarytool** - Replaces deprecated altool  
✅ **Hardened runtime** - Required security feature  
✅ **DMG signing** - Signs the distribution package  
✅ **Proper stapling** - Enables offline verification  

## Troubleshooting

### Certificate Issues
```bash
# List all certificates
security find-identity -v -p codesigning

# If you see expired certificates, remove them from Keychain Access
```

### Notarization Issues
```bash
# Check submission history
xcrun notarytool history --keychain-profile "notarization-password"

# Get details about a specific submission
xcrun notarytool info SUBMISSION-ID --keychain-profile "notarization-password"

# Get notarization log for debugging
xcrun notarytool log SUBMISSION-ID --keychain-profile "notarization-password"
```

### Verification Issues
```bash
# Check if app is properly signed
codesign --verify --deep --strict --verbose=2 dist/NameMyPdf.app

# Check if notarization ticket is attached
xcrun stapler validate dist/NameMyPdf.app

# Test Gatekeeper assessment
spctl --assess --type exec --verbose=4 dist/NameMyPdf.app
```

## Time Expectations

- **Code signing**: Instant
- **DMG creation**: 10-30 seconds
- **Notarization**: 2-15 minutes (Apple's servers)
- **Stapling**: 5-10 seconds

## Distribution

Once signed and notarized:

✅ **No security warnings** for users  
✅ **Runs on any Mac** without developer mode  
✅ **Works offline** after initial verification  
✅ **Professional appearance** in macOS  

The resulting DMG can be distributed through:
- GitHub Releases
- Your website
- Mac App Store (requires additional steps)
- Enterprise distribution

## Next Steps

After successful notarization, update your GitHub Actions workflow to use the new signing process for automated releases.