# NameMyPdf - Python Script Usage

If the main app doesn't work on your system (e.g., x86_64 Macs), you can run the Python script directly:

## Prerequisites:
1. Install Python 3.7+
2. Install poppler (for pdftotext):
   - macOS: `brew install poppler`
   - Ubuntu/Debian: `sudo apt-get install poppler-utils`
   - Windows: Download from https://poppler.freedesktop.org/
3. Install Python packages:
   `pip install -r requirements.txt`

## Usage:
python3 normalize_filename.py path/to/your/pdf/file.pdf

## What it does:
- Extracts text from PDF files using pdftotext
- Generates a descriptive filename based on DOI metadata from CrossRef
- Renames the file automatically

## Notes:
- The script looks for pdftotext in your PATH or in the same directory
- For Intel Macs, you'll need to install poppler separately since the included pdftotext is ARM64-only
- Set CROSSREF_EMAIL environment variable for better API rate limits

The Python script provides the same functionality as the compiled binary.
