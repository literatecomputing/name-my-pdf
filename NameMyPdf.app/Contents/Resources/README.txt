# NameMyPdf - PDF DOI Renamer

## Prerequisites:
This app requires poppler and jq to be installed:

```
brew install poppler jq
```

## Usage:
- Drag PDF files onto the app
- Or run the shell script directly: ./normalize_filename.sh file.pdf

## What it does:
- Extracts DOI from PDF files
- Fetches metadata from CrossRef API
- Renames files based on author, year, and title

## Notes:
- Set CROSSREF_EMAIL environment variable for better API rate limits
- Works on any system with bash, poppler, jq, and curl

Simple, lightweight, and reliable!
