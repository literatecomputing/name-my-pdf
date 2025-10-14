# Developer Guide

## Development Setup

### Prerequisites

- macOS (for building the app)
- [Homebrew](https://brew.sh/) package manager
- Git

### Install Development Dependencies

```bash
# Install Platypus for app building
brew install platypus

# Install create-dmg for DMG creation
brew install create-dmg

# Install runtime dependencies (for testing)
brew install poppler jq
```

## Building Locally

### Quick Build (for testing)

```bash
# Build app with Platypus
/usr/local/bin/platypus \
  --name "NameMyPdf" \
  --app-icon "icons/icon.icns" \
  --bundle-identifier "com.literatecomputing.namemypdf" \
  --author "Jay Pfaffman" \
  --app-version "1.0.0-dev" \
  --interface-type "Droplet" \
  --interpreter "/bin/bash" \
  --accepts-files \
  --accepts-text \
  --droppable \
  --background \
  --quit-after-execution \
  --text-droppable \
  --file-types "pdf" \
  --uniform-type-identifiers "com.adobe.pdf" \
  --minimum-version "10.11.0" \
  "normalize_filename.sh" \
  "NameMyPdf.app"
```

### Testing the App

```bash
# Test with a sample PDF (make sure it has DOI)
# Drag and drop a PDF onto NameMyPdf.app or run:
open -a NameMyPdf.app sample.pdf
```

## Release Process

### Automated Releases (Recommended)

1. **Create a release**:
   ```bash
   ./create-release.sh 1.1.0
   ```
2. **Monitor the build**: Check [GitHub Actions](https://github.com/literatecomputing/name-my-pdf/actions)

3. **Verify the release**: Visit the [releases page](https://github.com/literatecomputing/name-my-pdf/releases)

### Manual Release (if needed)

```bash
# Create ZIP
zip -r "NameMyPdf-v1.1.0.zip" "NameMyPdf.app" --exclude="*.DS_Store"

# Create DMG
mkdir -p dmg-contents
cp -R NameMyPdf.app dmg-contents/

create-dmg \
  --volname "NameMyPdf v1.1.0" \
  --volicon "icons/icon.icns" \
  --window-pos 200 120 \
  --window-size 800 450 \
  --icon-size 100 \
  --icon "NameMyPdf.app" 200 190 \
  --hide-extension "NameMyPdf.app" \
  --app-drop-link 600 190 \
  --hdiutil-quiet \
  "NameMyPdf-v1.1.0.dmg" \
  "dmg-contents/"
```

## GitHub Actions Workflow

The automated build process:

1. **Triggers**:

   - Push to tags matching `v*` (e.g., `v1.1.0`)
   - Manual workflow dispatch

2. **Steps**:

   - Checkout code
   - Install Platypus and create-dmg
   - Build app with Platypus
   - Create ZIP archive
   - Create DMG with drag-to-Applications UI
   - Create GitHub release with both assets

3. **Outputs**:
   - `NameMyPdf-v{version}.zip`
   - `NameMyPdf-v{version}.dmg`

## Project Structure

```
name-my-pdf/
├── .github/workflows/
│   └── build-release.yml      # GitHub Actions workflow
├── NameMyPdf.app/             # Built app bundle
├── icons/                     # App icons in various sizes
├── normalize_filename.sh      # Main script (executed by app)
├── icons/icon.icns                  # App icon for Platypus
├── README.md                  # Main documentation
├── INSTALL.md                 # User installation guide
├── create-release.sh          # Release creation script
└── ...
```

## Customizing the App

### Modifying the Script

Edit `normalize_filename.sh` to change the core functionality.

### Updating App Metadata

Modify the Platypus command in `.github/workflows/build-release.yml`:

- `--name`: App display name
- `--bundle-identifier`: Unique app identifier
- `--app-version`: Version number
- `--app-icon`: Icon file

### DMG Appearance

Customize the DMG in the workflow:

- `--window-size`: DMG window dimensions
- `--icon-size`: Icon size in DMG
- `--volname`: Volume name

## Testing

### Manual Testing

1. Build the app locally
2. Test with various PDF files:
   - PDFs with DOI
   - PDFs without DOI
   - Multiple PDFs (batch processing)
3. Verify the renaming logic
4. Test on different macOS versions

### Dependencies Testing

Ensure the app handles missing dependencies gracefully:

```bash
# Test without poppler
brew uninstall poppler
# Run app and verify error message

# Test without jq
brew uninstall jq
# Run app and verify error message
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

For major changes, please open an issue first to discuss the proposed changes.
