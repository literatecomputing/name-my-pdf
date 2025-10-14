# ✅ Apple Code Signing Action Plan

Here's your step-by-step plan to get NameMyPdf signed and notarized by Apple:

## Phase 1: Local Setup (30 minutes)

### 1. Verify Your Developer Certificates
```bash
# Check if you have the right certificate
security find-identity -v -p codesigning
# Look for: "Developer ID Application: Jay Pfaffman (B9YN7Q93P9)"
```

### 2. Set Up Notarization Credentials
```bash
# Store your notarization credentials
xcrun notarytool store-credentials "notarization-password" \
    --apple-id "jay@literatecomputing.com" \
    --team-id "B9YN7Q93P9"
# Enter your app-specific password when prompted
```
📋 **Need app-specific password?** → [Create one here](https://appleid.apple.com/account/manage)

### 3. Test Local Signing
```bash
# Build unsigned app
./bin/make-app-unsigned

# Sign and notarize (local version - uses your existing keychain)
./bin/sign-and-notarize-local
```

**Expected result:** Fully signed and notarized DMG in `dist/` folder.

---

## Phase 2: GitHub Actions Setup (15 minutes)

### 1. Export Certificate for GitHub
```bash
# Export your certificate from Keychain Access
# Save as .p12 with a password
# Convert to base64:
base64 -i /path/to/certificate.p12 | pbcopy
```

### 2. Set GitHub Secrets
Go to: **Your repo → Settings → Secrets and variables → Actions**

Create these secrets:
- `CERTIFICATE_BASE64` → Paste the base64 from step 1
- `P12_PASSWORD` → The password you used for the .p12
- `NOTARIZATION_PASSWORD` → Your app-specific password

### 3. Test Automated Build
```bash
# Test via manual workflow dispatch
# Go to Actions tab → "Build, Sign and Release NameMyPdf" → "Run workflow"
```

---

## Phase 3: Production Release (5 minutes)

```bash
# Create a signed release
./create-release.sh 1.0.1
```

**Result:** GitHub automatically builds, signs, notarizes, and releases your app! 🎉

---

## What You Get

### Before (Current State)
❌ "App can't be opened because it is from an unidentified developer"  
❌ Users must bypass security warnings  
❌ Manual approval required  

### After (Apple Signed)
✅ Opens immediately without warnings  
✅ Professional appearance  
✅ User trust and confidence  
✅ Works on all Macs out of the box  

---

## Time Investment vs. Benefit

| Task | Time | Benefit |
|------|------|---------|
| **Local setup** | 30 min | Test signing works |
| **GitHub setup** | 15 min | Automated releases |
| **First release** | 5 min | Professional distribution |
| **Future releases** | 0 min | Fully automated! |

**Total:** ~50 minutes of setup for professional, hassle-free distribution.

---

## Priority Order

1. **Start with local setup** - Verify everything works on your machine first
2. **Set up GitHub secrets** - Enable automated signing
3. **Test with manual workflow** - Verify GitHub Actions works
4. **Create production release** - Ship it! 

---

## Need Help?

- 📖 **Detailed guides**: `APPLE-SIGNING-GUIDE.md` and `GITHUB-SECRETS-SETUP.md`
- 🔧 **Scripts ready**: `bin/sign-and-notarize` and updated GitHub workflow
- 🚨 **Troubleshooting**: Check the guides for common issues and solutions

Your app is already great - now let's make the installation experience just as smooth! 🚀