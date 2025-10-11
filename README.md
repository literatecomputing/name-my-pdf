# NameMyPdf

NameMyPdf is a macOS application that automatically renames academic PDF files using metadata extracted from their DOI information. Simply drag and drop PDF files onto the app icon to get clean, standardized filenames in the format: `Author Year - Title.pdf`.

## 📥 Download & Install

### Latest Release

- **Download**: [Latest Release](https://github.com/literatecomputing/name-my-pdf/releases/latest)
- **Compatibility**: macOS 10.11.0+ (Universal: Intel & Apple Silicon)
- **Installation Guide**: See [INSTALL.md](./INSTALL.md) for detailed instructions

### Installation Options

#### Option 1: DMG Installer (Recommended)

1. Download the `.dmg` file from the latest release
2. Double-click to mount the disk image
3. Drag `NameMyPdf.app` to the Applications folder
4. Install dependencies: `brew install poppler jq`
5. Right-click the app and select "Open" for first launch

#### Option 2: ZIP Archive

1. Download the `.zip` file from the latest release
2. Extract and move `NameMyPdf.app` to your Applications folder
3. Install dependencies: `brew install poppler jq`
4. Right-click the app and select "Open" for first launch

### Quick Start

Drag PDF files onto the app icon to rename them automatically!

## ✨ Features

- **Universal Binary**: Native support for both Intel and Apple Silicon Macs
- **Drag & Drop Interface**: Easy-to-use file processing
- **Automatic DOI Detection**: Scans PDFs for DOI information
- **CrossRef Integration**: Fetches accurate publication metadata
- **Batch Processing**: Handle multiple files simultaneously
- **Clean Filenames**: Standardized `Author Year - Title` format

## 🛠 How It Works

1. **Extract DOI**: Scans the first 2 pages of each PDF for DOI information
2. **Fetch Metadata**: Queries CrossRef API for author, year, and title
3. **Generate Filename**: Creates clean, readable filename format
4. **Rename File**: Updates the file with the new standardized name

**Example**: A PDF with DOI `10.1000/182` becomes `Smith 2023 - Machine Learning Applications.pdf`

## 📋 System Requirements

- **macOS**: 10.11.0 (El Capitan) or later
- **Dependencies**: `poppler`, `jq`, `curl` (install via Homebrew)
- **Internet**: Required for metadata lookup

## 🔧 Development

### Automated Builds

This repository uses GitHub Actions to automatically build and release the app when you push a git tag:

```bash
# Create and push a new release
git tag v1.1.0
git push origin v1.1.0
```

The workflow will:

- Build the app using Platypus on macOS runners
- Create both ZIP and DMG distribution packages
- Generate a GitHub release with download links
- Include professional DMG with drag-to-Applications interface

### Manual Builds

You can also trigger builds manually from the GitHub Actions tab, or build locally using Platypus.

### API Usage

Per CrossRef documentation, we include a User-Agent header and recommend adding an email for API identification:

> If you're using a script or app that regularly queries our API, add a User-Agent header. This can help us to troubleshoot issues and give you more specific feedback if we do need to contact you.

Source: [CrossRef REST API Tips](https://www.crossref.org/documentation/retrieve-metadata/rest-api/tips-for-using-the-crossref-rest-api/)

## 📝 Release Notes

See [RELEASE-NOTES-v1.0.md](./RELEASE-NOTES-v1.0.md) for detailed information about this release.

## 📄 License

© 2025 Jay Pfaffman - See repository for license details.
