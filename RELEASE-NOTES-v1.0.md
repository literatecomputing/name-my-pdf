# NameMyPdf v1.0 Release Notes

## What's New in v1.0

This is the initial release of NameMyPdf, a macOS application that automatically renames academic PDF files based on their DOI metadata.

### Features

✅ **Universal Binary**: Supports both Intel and Apple Silicon Macs  
✅ **Drag & Drop Interface**: Simply drag PDF files onto the app icon  
✅ **Automatic DOI Detection**: Scans PDFs for DOI information  
✅ **CrossRef Integration**: Fetches accurate metadata from CrossRef API  
✅ **Clean Filename Generation**: Creates standardized "Author Year - Title" format  
✅ **Batch Processing**: Handle multiple PDFs at once

### Technical Details

- **Minimum macOS**: 10.11.0 (El Capitan)
- **App Size**: ~1.5MB
- **Dependencies**: Requires `poppler` and `jq` (install via Homebrew)
- **API**: Uses CrossRef REST API for metadata retrieval

### File Format

- **Input**: PDF files containing DOI information
- **Output**: Renamed files in format: `Author YEAR - Title.pdf`
- **Example**: `Smith 2023 - Machine Learning Applications.pdf`

## Installation

1. Download `NameMyPdf-v1.0.zip`
2. Extract and move `NameMyPdf.app` to Applications folder
3. Install dependencies: `brew install poppler jq`
4. Right-click app and select "Open" for first launch (security)

## Known Limitations

- Requires internet connection for metadata lookup
- Only processes PDFs with embedded DOI information
- Titles are truncated to first 5 words or text before colon
- Unsigned app requires manual security approval

## Coming Soon

- DMG installer package
- Code signing for easier installation
- Support for additional metadata sources
- Customizable filename templates

---

**Download**: NameMyPdf-v1.0.zip (1.5MB)  
**Compatibility**: macOS 10.11.0+ (Intel & Apple Silicon)  
**Released**: October 2025
