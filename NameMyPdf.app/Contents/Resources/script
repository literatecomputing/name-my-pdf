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
import requests
import unicodedata
from pathlib import Path
from typing import Optional, List

def check_dependencies():
    """Check if required external tools are available."""
    required_tools = ['pdftotext']
    missing_tools = []
    
    for tool in required_tools:
        try:
            subprocess.run([tool, '--version'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except FileNotFoundError:
            missing_tools.append(tool)
    
    if missing_tools:
        print(f"Missing required tools: {', '.join(missing_tools)}")
        print("Please install poppler-utils (or 'brew install poppler' on macOS)")
        sys.exit(1)

def get_doi_from_pdf_file(pdf_path: str) -> Optional[str]:
    """Extract DOI from PDF file using pdftotext."""
    try:
        # Use pdftotext to extract first 2 pages
        result = subprocess.run(
            ['pdftotext', pdf_path, '-l', '2', '-'],
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
    params = {'mailto': email}
    
    try:
        response = requests.get(url, params=params, timeout=30)
        
        if response.status_code == 404:
            print(f"DOI {doi} not found")
            return None
            
        response.raise_for_status()
        return response.json()
        
    except requests.exceptions.RequestException as e:
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
        required=True,
        help='Email address for CrossRef API (required for etiquette)'
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
