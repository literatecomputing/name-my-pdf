# NameMyPdf - Shell Script Usage

This app includes universal binaries that work on both Apple Silicon and Intel Macs!

If you need to run the shell script directly:

## Prerequisites:
The app already includes both ARM64 and Intel versions of required tools.

For standalone use on other systems:
1. Install required tools:
   - macOS: `brew install poppler jq`
   - Ubuntu/Debian: `sudo apt-get install poppler-utils jq curl`
   - Other systems: Install poppler, jq, and curl

## Usage:
./normalize_filename.sh [--email your@email.com] file1.pdf file2.pdf

## What it does:
- Extracts text from PDF files using pdftotext
- Generates a descriptive filename based on DOI metadata from CrossRef
- Renames the file automatically

## Notes:
- The bundled tools automatically detect your Mac's architecture (ARM64/Intel)
- Set CROSSREF_EMAIL environment variable for better API rate limits
- Works on any Unix-like system (macOS, Linux, WSL)

The shell script provides the same functionality as the compiled app.
