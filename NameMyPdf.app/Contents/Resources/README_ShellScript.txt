# NameMyPdf - Shell Script Usage

If the main app doesn't work on your system, you can run the shell script directly:

## Prerequisites:
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
- Set CROSSREF_EMAIL environment variable for better API rate limits
- Works on any Unix-like system (macOS, Linux, WSL)

The shell script provides the same functionality as the compiled app.
