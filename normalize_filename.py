#!/usr/bin/env python3
"""
PDF DOI Renamer
Takes a list of PDF files and renames them according to their DOI metadata.
Requires PyPDF2 and requests libraries.
"""

import os
import sys
import re
import subprocess
import argparse
import json
import urllib.request
import urllib.error
import unicodedata
import shutil
from pathlib import Path
from typing import Optional, List
# add constant for user agent
USER_AGENT = "PDF DOI Renamer/1.0 (https://github.com/literatecomputing/name-my-pdf)"

def get_pdftotext_path() -> str:
    """Get path to pdftotext executable."""
    # First try system PATH
    pdftotext_path = shutil.which('pdftotext')
    if pdftotext_path:
        return pdftotext_path
    
    # Try bundled version in same directory
    script_dir = Path(__file__).parent
    bundled_pdftotext = script_dir / 'pdftotext'
    if bundled_pdftotext.exists() and bundled_pdftotext.is_file():
        return str(bundled_pdftotext)
    
    print("pdftotext is not installed and not found in the script directory.")
    print("Please install poppler: brew install poppler")
    sys.exit(1)

def get_doi_from_pdf_file(pdf_path: str) -> Optional[str]:
    """Extract DOI from PDF file using pdftotext."""
    pdftotext_path = get_pdftotext_path()
    
    try:
        # Use pdftotext to extract first 2 pages
        result = subprocess.run(
            [pdftotext_path, pdf_path, '-l', '2', '-'],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        
        if result.returncode != 0:
            print(f"Error extracting text from {pdf_path}")
            return None
            
        text = result.stdout
        # Replace newlines with spaces and fix slash-space issues
        text = text.replace('\n', ' ').replace('/ ', '/')
        
        # Find DOI pattern
        doi_pattern = r'10\.[0-9]{4,9}/[a-zA-Z0-9/:._-]*'
        matches = re.findall(doi_pattern, text)
        
        if matches:
            return matches[-1]  # Return the last match (equivalent to tail -1)
        
        return None
        
    except Exception as e:
        print(f"Error processing {pdf_path}: {e}")
        return None

def remove_accents(text: str) -> str:
    """Remove accents from text and convert to ASCII."""
    try:
        # First try using unicodedata
        text = unicodedata.normalize('NFD', text)
        text = ''.join(c for c in text if unicodedata.category(c) != 'Mn')
        
        # Additional manual replacements for common characters
        replacements = {
            'ć': 'c', 'š': 's', 'ž': 'z', 'đ': 'd', 'ş': 's', 
            'ö': 'o', 'ü': 'u', 'ı': 'i', 'ğ': 'g', 'ç': 'c'
        }
        
        for old, new in replacements.items():
            text = text.replace(old, new)
            text = text.replace(old.upper(), new.upper())
            
        return text
        
    except Exception:
        return text

def capitalize_author_name(name: str) -> str:
    """Capitalize author name properly."""
    # Only capitalize if the name is all uppercase or all lowercase
    if name.isupper() or name.islower():
        return name.capitalize()
    else:
        # Name has mixed case, preserve it
        return name

def get_crossref_metadata(doi: str, email: str) -> Optional[dict]:
    """Fetch metadata from CrossRef API."""
    url = f"https://api.crossref.org/works/{doi}"
    
    # Prepare headers
    headers = {'User-Agent': USER_AGENT}
    if not email and 'CROSSREF_EMAIL' in os.environ:
        email = os.getenv('CROSSREF_EMAIL')
    if email:
        headers['X-CrossRef-Email'] = email

    try:
        # Create request with headers
        req = urllib.request.Request(url, headers=headers)
        
        print("Using url", url)
        
        with urllib.request.urlopen(req, timeout=30) as response:
            if response.status == 404:
                print(f"DOI {doi} not found")
                return None
            
            # Read and decode response
            data = response.read().decode('utf-8')
            return json.loads(data)
        
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"DOI {doi} not found")
            return None
        print(f"HTTP error fetching metadata for {doi}: {e}")
        return None
    except urllib.error.URLError as e:
        print(f"URL error fetching metadata for {doi}: {e}")
        return None
    except Exception as e:
        print(f"Error fetching metadata for {doi}: {e}")
        return None

def extract_metadata(json_data: dict) -> dict:
    """Extract relevant metadata from CrossRef response."""
    message = json_data.get('message', {})
    
    # Extract author
    authors = message.get('author', [])
    if not authors:
        raise ValueError("No author found")
    
    author = authors[0].get('family', '')
    if not author:
        raise ValueError("No author family name found")
    
    # Clean and capitalize author name
    author = remove_accents(author)
    author = re.sub(r'[^a-zA-Z0-9]', '', author)
    author = capitalize_author_name(author)
    
    # Extract journal
    journal = (message.get('short-container-title', [None])[0] or 
              message.get('container-title', [None])[0])
    
    if not journal:
        raise ValueError("No journal found")
    
    # Extract title
    titles = message.get('title', [])
    if not titles:
        raise ValueError("No title found")
    
    title = titles[0]
    # Strip HTML tags
    title = re.sub(r'<[^>]*>', ' ', title)
    # Remove non-alphanumeric characters except spaces
    title = re.sub(r'[^a-zA-Z0-9\s]', '', title)

    # remove words like "the", "a", "an" from the title
    title = re.sub(r'\b(the|a|an|and|but|or|nor|for|so|yet|of|in|on|at|to|by|up|as|is|it|be|if|vs|via|per|pro|re|ex)\b', 
               lambda m: m.group(0).lower(), title, flags=re.IGNORECASE)
    title = re.sub(r'\b(the|a|an|and|but|or|nor|for|so|yet|of|in|on|at|to|by|up|as|is|it|be|if|vs|via|per|pro|re|ex)\b', '', title, flags=re.IGNORECASE)

    # Extract year
    year = None
    for date_field in ['published-print', 'published-online', 'created']:
        date_parts = message.get(date_field, {}).get('date-parts', [[]])
        if date_parts and date_parts[0]:
            year = date_parts[0][0]
            break
    
    # Try journal-issue as fallback
    if not year:
        journal_issue = message.get('journal-issue', {})
        date_parts = journal_issue.get('published-print', {}).get('date-parts', [[]])
        if date_parts and date_parts[0]:
            year = date_parts[0][0]
    
    if not year:
        raise ValueError("No year found")
    
    return {
        'author': author,
        'journal': journal,
        'title': title,
        'year': year
    }

def generate_filename(metadata: dict) -> str:
    """Generate new filename from metadata."""
    author = metadata['author']
    year = metadata['year']
    title = metadata['title']
    
    # Get short title (first 5 words or everything before colon)
    if ':' in title:
        title_part = title.split(':')[0]
    else:
        title_part = title
    
    words = title_part.split()[:5]
    short_title = ' '.join(words)
    
    return f"{author} {year} - {short_title}"

def process_pdf(pdf_path: str, email: str) -> bool:
    """Process a single PDF file."""
    print(f"Processing: {pdf_path}")
    
    # Get DOI from PDF
    doi = get_doi_from_pdf_file(pdf_path)
    if not doi:
        print(f"No DOI found in {pdf_path}")
        return False
    
    print(f"Found DOI: {doi}")
    
    # Get metadata from CrossRef
    json_data = get_crossref_metadata(doi, email)
    if not json_data:
        return False
    
    try:
        metadata = extract_metadata(json_data)
    except ValueError as e:
        print(f"Error extracting metadata: {e}")
        return False
    
    # Generate new filename
    new_filename = generate_filename(metadata)
    
    # Get paths
    pdf_path_obj = Path(pdf_path)
    new_path = pdf_path_obj.parent / f"{new_filename}.pdf"
    
    # Check if target file already exists
    if new_path.exists():
        print(f"Target file already exists: {new_path}")
        return False
    
    try:
        # Rename file
        pdf_path_obj.rename(new_path)
        print(f"Renamed: {pdf_path} -> {new_path}")
        return True
    except Exception as e:
        print(f"Error renaming file: {e}")
        return False

def check_dependencies():
    """Check if required dependencies are available."""
    try:
        get_pdftotext_path()
        print("Dependencies check passed")
    except SystemExit:
        print("Dependency check failed")
        raise

def main():
    parser = argparse.ArgumentParser(
        description="Rename PDF files based on their DOI metadata"
    )
    parser.add_argument(
        'files', 
        nargs='+', 
        help='PDF files to process'
    )
    parser.add_argument(
        '--email', 
        required=False,
        help='Email address for CrossRef API (https://www.crossref.org/documentation/retrieve-metadata/rest-api/tips-for-using-the-crossref-rest-api/)'
    )
    
    args = parser.parse_args()
    
    # Check dependencies
    check_dependencies()
    
    # Process each file
    success_count = 0
    for pdf_file in args.files:
        if not os.path.exists(pdf_file):
            print(f"File not found: {pdf_file}")
            continue
            
        if not pdf_file.lower().endswith('.pdf'):
            print(f"Skipping non-PDF file: {pdf_file}")
            continue
            
        if process_pdf(pdf_file, args.email):
            success_count += 1
    
    print(f"\nProcessed {success_count} out of {len(args.files)} files successfully")

if __name__ == "__main__":
    main()
