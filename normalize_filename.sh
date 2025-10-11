#!/usr/bin/env bash
# take a list of pdf files and rename them according to the DOI
# Zotero will also rename files according to the DOI, but it uses full author names, year, full title, which is a bit long for my taste
# Requires pdftotext, jq, and curl. According to Github Copilot, on a Mac, you can install these with brew install poppler jq curl
# https://support.datacite.org/docs/datacite-doi-display-guidelines suggests that "DOI: 10.1234/5678" is not recommended for displaying DOIs, so maybe we should search for https://doi.org/10. instead of just DOI:
# This works on virtually every PDF I've downloaded in 2024 and almost none from a decade before.
# This might be a more rubust way to get the DOI: https?:\/\/.*?doi\.org\/(10\.[0-9]*?\/.*)\s|DOI:?\s?(10\..*?\/.*?)\s
# It'll find old-style DOIs like DOI: 10.1002/2017GL074677 or new-style DOIs like https://doi.org/10.1002/2017GL074677

## OMG. Looks like this would have been much, much, simpler this way
# https://www.crossref.org/documentation/retrieve-metadata/xml-api/using-https-to-query/#00418
# curl https://doi.crossref.org/servlet/query?pid=$CROSSREF_EMAIL&id=$DOI
# returns something like:
# 0026-7902,1540-4781|The Modern Language Journal|Afreen|108|S1|75|2024|full_text||10.1111/modl.12900
# So then you can just get those PIPE-delimited fields and no json fussing
# but that has bogus years much of the time

if [[ ! -f ~/.namemypdfrc ]];then
  echo "Creating ~/.namemypdfrc -- edit to change how files are named"
  cat <<EOF > ~/.namemypdfrc
# This is the configuration file for NameMyPdf. You can change
# these settings to control how your PDFs are renamed.
#
# Hopefully, the settings are clear from their names. . .
#
# Optionally let crossref know it's you--recommended if you're naming hundreds of files
# CROSSREF_EMAIL=you@email.com
DOWNCASE_TITLE=false
TITLE_WORDS=7 # number of words from title to include
TITLE_WORD_SEPARATOR=" "
AUTHOR_YEAR_SEPARATOR=" "
YEAR_TITLE_SEPARATOR=" - "
USE_ABBR_TITLE=false  # use only first letter of title words
STRIP_TITLE_POST_COLON=true # shorten title to before the colon
DEBUG=false
EOF
  open -e ~/.namemypdfrc
fi
source ~/.namemypdfrc

if [[ "$OSTYPE" == "darwin"* ]]; then
  got_brew=false
  # Add Homebrew paths to PATH for both Intel and Apple Silicon
  # Apple Silicon path
  if [[ -d "/opt/homebrew/bin" ]]; then
    got_brew=true
    export PATH="/opt/homebrew/bin:$PATH"
  fi
  # Intel path
  if [[ -d "/usr/local/bin" ]]; then
    got_brew=true
    export PATH="/usr/local/bin:$PATH"
  fi
  if [[ ! $got_brew ]];then
    echo "ALERT:Configuration|Homebrew is required"
  fi
fi

# Find tools explicitly - check bundled binaries first, then common Homebrew locations
find_tool() {
  local tool=$1
  
  # Get the directory of the script (handles being run from within app bundle)
  local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  
  # First check if we have a bundled binary (in the same directory as the script)
  if [[ -f "$script_dir/$tool" ]] && [[ -x "$script_dir/$tool" ]]; then
    echo "$script_dir/$tool"
    return 0
  fi
  
  # Then try command -v (uses PATH)
  if command -v "$tool" &> /dev/null; then
    command -v "$tool"
    return 0
  fi
  
  # Then check Homebrew locations directly
  if [[ -f "/opt/homebrew/bin/$tool" ]]; then
    echo "/opt/homebrew/bin/$tool"
    return 0
  fi
  if [[ -f "/usr/local/bin/$tool" ]]; then
    echo "/usr/local/bin/$tool"
    return 0
  fi
  return 1
}

# Find and set absolute paths for tools
PDFTOTEXT=$(find_tool pdftotext)
JQ=$(find_tool jq)
CURL=$(find_tool curl)

# Debug: Show what we found
echo "DEBUG: PDFTOTEXT=$PDFTOTEXT"
echo "DEBUG: JQ=$JQ"
echo "DEBUG: CURL=$CURL"
echo "DEBUG: PATH=$PATH"

if [[ -z "$PDFTOTEXT" ]]; then
    echo "pdftotext is missing. Please install poppler-utils or on a mac 'brew install poppler'"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "ALERT:Configuration|Install poppler in a terminal with 'brew install poppler'"
    fi
    exit 1
fi

if [[ -z "$JQ" ]]; then
    echo "jq is missing. Please install jq or on a mac 'brew install jq'"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "ALERT:Configuration|Install jq in a terminal with 'brew install jq'"
    fi
    exit 1
fi

if [[ -z "$CURL" ]]; then
    echo "curl is missing. Please install curl or on a mac 'brew install curl'"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "ALERT:Configuration|Install curl in a terminal with 'brew install curl'"
    fi
    exit 1
fi


get_doi_from_pdf_file() {
  local pdf="$1"
  # pdftotext: get first page of PDF
  # tr: replace newlines with spaces (sometimes a newline will break the between DOI: and DOI or break DOI into two lines)
  # sed: replace slash-space with slash (sometimes the DOI is split at the slash which we replaced with a space)
  # grep: get the line with the DOI (but that's the whole thing?
  # awk: split the line at DOI:, leaving the DOI and the rest of the line
  # awk: get just the first word (the DOI)
  DOI=$("$PDFTOTEXT" "$pdf" -l 2  -  2> /dev/null |tr '\n' ' ' | sed 's|/ |/|' | grep -Eo '10\.[0-9]{4,9}/[a-zA-Z0-9/:._-]*' 2> /dev/null|tail -1 )
  echo $DOI
}

get_doi_url_from_pdf_file() {
  local pdf="$1"
  # pdftotext: get first page of PDF
  # tr: replace newlines with spaces (sometimes a newline will break the between DOI: and DOI or break DOI into two lines)
  # sed: replace slash-space with slash (sometimes the DOI is split at the slash which we replaced with a space)
  # grep: get the line with the DOI (but that's the whole thing?
  # awk: split the line at DOI:, leaving the DOI and the rest of the line
  # awk: get just the first word (the DOI)
  DOI=$("$PDFTOTEXT" "$pdf" -l 1  -   2> /dev/null |tr '\n' ' ' | sed 's|/ |/|' | grep -Eo '10\.[0-9]{4,9}/[a-zA-Z0-9/:._-]*'|tail -1 | awk '{print "https://doi.org/"$1}')
  echo "get_doi_url_from_pdf_file: $DOI"
  echo $DOI
}

capitalize_author_name() {
  local name="$1"
  # Fix bogus author name capitalization
  # Only capitalize if the name is all uppercase or all lowercase
  # Preserve mixed case names like "deCosta", "van der Berg", etc.
  if [[ "$name" =~ ^[A-Z]+$ ]] || [[ "$name" =~ ^[a-z]+$ ]]; then
    # Convert to title case: first letter uppercase, rest lowercase
    echo "${name:0:1}$(echo "${name:1}" | tr '[:upper:]' '[:lower:]')"
  else
    # Name has mixed case, preserve it
    echo "$name"
  fi
}

for item in "$@"; do
  # Get full path for the input file
  ITEM_ABS_PATH=$(realpath "$item")
  ITEM_DIR=$(dirname "$ITEM_ABS_PATH")

  DOI=$(get_doi_from_pdf_file "$ITEM_ABS_PATH")
  if [[ -z $DOI ]];then
    echo "No DOI found in $item, skipping"
    continue
  fi
  FILE_DOI=$(echo $DOI|sed 's|/|_|g')
  if [[ -z "$CROSSREF_EMAIL" ]];then
    MAILTO=""
  else
    MAILTO="?mailto=$CROSSREF_EMAIL"
  fi
  echo "$item" -- Getting "https://api.crossref.org/works/$DOI$MAILTO"
  json=$("$CURL" -s "https://api.crossref.org/works/$DOI$MAILTO")
  if [[ $DEBUG = "true" ]];then
    echo got json
  fi
  if echo "$json" | grep -q "Resource not found."; then
    echo "$item: $DOI --- not found"
    continue
  fi

  author=$(echo $json|"$JQ" -r '.message.author[0].family')
  if [[ $DEBUG = "true" ]];then
    echo author: $author
  fi
  if [ -z "$author" ] || [ "$author" = "null" ]; then
    echo "Failed to extract author. Skipping $item"
    continue
  fi
  # Capitalize author name properly
  # Remove accents from author name
  author=$(echo "$author" | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null)
  # If iconv failed or didn't transliterate properly, use sed for common accents
  if [[ "$author" =~ [^[:ascii:]] ]]; then
    author=$(echo "$author" | sed 'y/àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ/aaaaaaeceeeeiiiidnooooooouuuyty/' | sed 'y/ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸ/aaaaaaeceeeeiiiidnooooooouuuyty/' | sed 's/ć/c/g; s/š/s/g; s/ž/z/g; s/đ/d/g; s/ş/s/g; s/ö/o/g; s/ü/u/g; s/ı/i/g; s/ğ/g/g; s/ç/c/g')
  fi
  # Convert to lowercase and remove any remaining non-ASCII
  # author=$(echo "$author" | sed 's/[^[:alnum:]]//g')
  author=$(capitalize_author_name "$author")

  if [[ $DEBUG = "true" ]];then
    echo author: $author
  fi

  title=$(echo $json|"$JQ" -r '.message.title | .[]')
  # Strip HTML tags from title (especially <i> tags for italics)
  title=$(echo "$title" | sed 's/<[^>]*>/ /g')
  # strip non alpha numbers from title
  title=$(echo "$title" | sed 's/[^[:alnum:][:space:]:]//g')
  if [[ $DEBUG = "true" ]];then
    echo title: $title
  fi
  # make all letters non-accented and lowercase
  # title=$(echo "$title" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')
  # first five words of title, but stop at colon if present
  if [[ $STRIP_TITLE_POST_COLON && "$title" == *":"* ]]; then
    # Extract everything before the first colon
    title="${title%%:*}"
  fi

  if [[ $DOWNCASE_TITLE = 'true' ]];then
    title=$(echo "$title" | tr '[:upper:]' '[:lower:]')
  fi

  short_title=$(echo "$title" | awk -v n="$TITLE_WORDS" '{for(i=1;i<=n && i<=NF;i++) printf "%s%s", $i, (i<n && i<NF ? " " : "")}' | sed "s| |$TITLE_WORD_SEPARATOR|g" | sed 's/_*$//')    # allow only letters and numbers in title
  # first letter of first five words of title (lowercase)
  if [[ $DEBUG = "true" ]];then
    echo shorttitle: $short_title
  fi
  abbr_title=$(echo "$title" | awk -v n="$TITLE_WORDS" '{for(i=1;i<=n && i<=NF;i++) printf "%s", substr($i,1,1)}')
  # make short_journal be the first letter of each word in the journal name
  # journal is currently not used, but here it is if someone wants it
  journal=$(echo "$json" | "$JQ" -r '.message["short-container-title"][0] // .message["container-title"][0]')
  short_j=$(echo $journal|awk '{for(i=1;i<=NF;i++) printf "%s", substr($i,1,1)}')
  # year can be in several places and can be different (e.g., published, vs online)
  year=$(echo $json|"$JQ" -r '
  .message["published-print"]["date-parts"][0][0] //
  .message["journal-issue"]["published-print"]["date-parts"][0][0] //
  .message["published-online"]["date-parts"][0][0] //
  .message.created["date-parts"][0][0]')
  if [ -z "$year" ] || [ "$year" = "null" ]; then
    echo "Failed to extract year"
    year="XXXX"
  fi

  target_title=$short_title
  if [[ $USE_ABBR_TITLE == true ]];then
    target_title="$abbr_title"
  fi

  target_filename="$author$AUTHOR_YEAR_SEPARATOR$year$YEAR_TITLE_SEPARATOR$target_title"
  target_path="$ITEM_DIR/$target_filename.pdf"


  if [[ $DEBUG = "true" ]];then
    echo filename: $target_filename
  fi

  # Check if target file already exists
  if [[ -f "$target_path" ]]; then
    echo "Target file already exists: $target_path"
  else
    echo "Renaming: $item -> $target_filename"
    mv "$ITEM_ABS_PATH" "$target_path"
  fi
done
