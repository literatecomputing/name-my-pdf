#!/bin/bash

# PDF DOI Renamer - Shell Script Version
# Takes PDF files and renames them according to their DOI metadata
# Requires: pdftotext, curl, jq

USER_AGENT="PDF DOI Renamer/1.0 (https://github.com/literatecomputing/name-my-pdf)"

# Check if required tools are available
check_dependencies() {
    local missing_tools=()
    
    # Check for pdftotext (try bundled version first)
    if [[ -f "$(dirname "$0")/pdftotext" ]]; then
        PDFTOTEXT="$(dirname "$0")/pdftotext"
    elif command -v pdftotext >/dev/null 2>&1; then
        PDFTOTEXT="pdftotext"
    else
        missing_tools+=("pdftotext (install with: brew install poppler)")
    fi
    
    # Check for jq (try bundled version first)
    if [[ -f "$(dirname "$0")/jq" ]]; then
        JQ="$(dirname "$0")/jq"
    elif command -v jq >/dev/null 2>&1; then
        JQ="jq"
    else
        missing_tools+=("jq (install with: brew install jq)")
    fi
    
    # Check for curl (should be available on all systems)
    command -v curl >/dev/null 2>&1 || missing_tools+=("curl")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "Missing required tools:"
        printf "  %s\n" "${missing_tools[@]}"
        exit 1
    fi
}

# Extract DOI from PDF file
get_doi_from_pdf() {
    local pdf_path="$1"
    
    # Extract text from first 2 pages and look for DOI
    "$PDFTOTEXT" "$pdf_path" -l 2 - 2>/dev/null | \
        tr '\n' ' ' | \
        sed 's/\/ /\//g' | \
        grep -oE '10\.[0-9]{4,9}/[a-zA-Z0-9/:._-]+' | \
        tail -1
}

# Remove accents and clean text
clean_text() {
    local text="$1"
    # Remove common accents and non-ASCII characters
    echo "$text" | sed 's/[àáâãäå]/a/g; s/[èéêë]/e/g; s/[ìíîï]/i/g; s/[òóôõö]/o/g; s/[ùúûü]/u/g; s/[ýÿ]/y/g; s/[ñ]/n/g; s/[ç]/c/g; s/[ÀÁÂÃÄÅ]/A/g; s/[ÈÉÊË]/E/g; s/[ÌÍÎÏ]/I/g; s/[ÒÓÔÕÖ]/O/g; s/[ÙÚÛÜ]/U/g; s/[Ý]/Y/g; s/[Ñ]/N/g; s/[Ç]/C/g'
}

# Get metadata from CrossRef API
get_crossref_metadata() {
    local doi="$1"
    local email="${2:-$CROSSREF_EMAIL}"
    local url="https://api.crossref.org/works/$doi"
    
    local headers="-H 'User-Agent: $USER_AGENT'"
    if [[ -n "$email" ]]; then
        headers="$headers -H 'X-CrossRef-Email: $email'"
    fi
    
    echo "Using URL: $url" >&2
    
    # Use eval to properly handle the headers
    eval "curl -s $headers '$url'" 2>/dev/null
}

# Extract author from JSON
extract_author() {
    local json="$1"
    echo "$json" | "$JQ" -r '.message.author[0].family // empty' | clean_text
}

# Extract year from JSON
extract_year() {
    local json="$1"
    echo "$json" | "$JQ" -r '
        .message 
        | (."published-print"."date-parts"[0][0] // 
           ."published-online"."date-parts"[0][0] // 
           .created."date-parts"[0][0] // 
           ."journal-issue"."published-print"."date-parts"[0][0] // 
           empty)
    '
}

# Extract title from JSON
extract_title() {
    local json="$1"
    echo "$json" | "$JQ" -r '.message.title[0] // empty' | \
        sed 's/<[^>]*>//g' | \
        sed 's/[^a-zA-Z0-9 ]//g' | \
        sed -E 's/\b(the|a|an|and|but|or|nor|for|so|yet|of|in|on|at|to|by|up|as|is|it|be|if|vs|via|per|pro|re|ex)\b//gi' | \
        sed 's/  */ /g' | \
        sed 's/^ *//; s/ *$//'
}

# Generate filename from metadata
generate_filename() {
    local author="$1"
    local year="$2"
    local title="$3"
    
    # Get short title (first 5 words or everything before colon)
    local short_title
    if [[ "$title" == *":"* ]]; then
        short_title=$(echo "$title" | cut -d':' -f1)
    else
        short_title="$title"
    fi
    
    # Take first 5 words
    short_title=$(echo "$short_title" | awk '{for(i=1;i<=5 && i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ *$//')
    
    echo "${author} ${year} - ${short_title}"
}

# Process a single PDF file
process_pdf() {
    local pdf_path="$1"
    local email="$2"
    
    echo "Processing: $pdf_path"
    
    # Get DOI from PDF
    local doi
    doi=$(get_doi_from_pdf "$pdf_path")
    if [[ -z "$doi" ]]; then
        echo "No DOI found in $pdf_path"
        return 1
    fi
    
    echo "Found DOI: $doi"
    
    # Get metadata from CrossRef
    local json
    json=$(get_crossref_metadata "$doi" "$email")
    if [[ -z "$json" ]] || [[ "$json" == *'"status":"error"'* ]]; then
        echo "Error fetching metadata for DOI: $doi"
        return 1
    fi
    
    # Extract metadata
    local author year title
    author=$(extract_author "$json")
    year=$(extract_year "$json")
    title=$(extract_title "$json")
    
    if [[ -z "$author" ]] || [[ -z "$year" ]] || [[ -z "$title" ]]; then
        echo "Error: Missing required metadata (author: '$author', year: '$year', title: '$title')"
        return 1
    fi
    
    # Generate new filename
    local new_filename
    new_filename=$(generate_filename "$author" "$year" "$title")
    local new_path="$(dirname "$pdf_path")/${new_filename}.pdf"
    
    # Check if target file already exists
    if [[ -f "$new_path" ]]; then
        echo "Target file already exists: $new_path"
        return 1
    fi
    
    # Rename file
    if mv "$pdf_path" "$new_path"; then
        echo "Renamed: $pdf_path -> $new_path"
        return 0
    else
        echo "Error renaming file"
        return 1
    fi
}

# Main function
main() {
    local email=""
    local files=()
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --email)
                email="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [--email EMAIL] FILE..."
                echo "Rename PDF files based on their DOI metadata"
                echo ""
                echo "Options:"
                echo "  --email EMAIL    Email address for CrossRef API"
                echo "  --help, -h       Show this help message"
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                exit 1
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Error: No PDF files specified"
        echo "Usage: $0 [--email EMAIL] FILE..."
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Process each file
    local success_count=0
    for pdf_file in "${files[@]}"; do
        if [[ ! -f "$pdf_file" ]]; then
            echo "File not found: $pdf_file"
            continue
        fi
        
        if [[ ! "$pdf_file" =~ \.[pP][dD][fF]$ ]]; then
            echo "Skipping non-PDF file: $pdf_file"
            continue
        fi
        
        if process_pdf "$pdf_file" "$email"; then
            ((success_count++))
        fi
    done
    
    echo ""
    echo "Processed $success_count out of ${#files[@]} files successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
