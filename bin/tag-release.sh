#!/bin/bash
# tag-release.sh: Tag and push a new release, and update DMG/ZIP links and version/date in docs and README.
# Usage:
#   ./tag-release.sh [tagname]
# If [tagname] is omitted, prints the most recent tag.

set -e

if [ "$1" = "" ]; then
    # Show the most recent tag
    git describe --tags --abbrev=0
    exit 0
fi

TAG="$1"
DMG="NameMyPdf-$TAG.dmg"
ZIP="NameMyPdf-$TAG.zip"
RELEASE_URL="https://github.com/literatecomputing/name-my-pdf/releases/download/$TAG"
TODAY=$(date '+%B %d, %Y')

# Update DMG/ZIP links in README.md
sed -i.bak "/VERSION-UPDATE-START/,/VERSION-UPDATE-END/c\\
<!-- VERSION-UPDATE-START -->\n- **Download DMG**: [$DMG]($RELEASE_URL/$DMG)\n- **Download ZIP**: [$ZIP]($RELEASE_URL/$ZIP)\n<!-- VERSION-UPDATE-END -->" README.md && rm README.md.bak

# Update download buttons in docs/download.md
sed -i.bak "s|https://github.com/literatecomputing/name-my-pdf/releases/download/v[0-9]\+\.[0-9]\+\.[0-9]\+/NameMyPdf-v[0-9]\+\.[0-9]\+\.[0-9]\+\.dmg|$RELEASE_URL/$DMG|g" docs/download.md && rm docs/download.md.bak
sed -i.bak "s|https://github.com/literatecomputing/name-my-pdf/releases/download/v[0-9]\+\.[0-9]\+\.[0-9]\+/NameMyPdf-v[0-9]\+\.[0-9]\+\.[0-9]\+\.zip|$RELEASE_URL/$ZIP|g" docs/download.md && rm docs/download.md.bak

# Update version and date in docs/download.md
sed -i.bak "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/${TAG}/g" docs/download.md && rm docs/download.md.bak
sed -i.bak "s/\*\*Last Updated:\*\* .*/\*\*Last Updated:\*\* $TODAY/g" docs/download.md && rm docs/download.md.bak

# Update quick start and button in docs/index.md
sed -i.bak "s|\[Download Latest Release\](/download.html).*VERSION-UPDATE-MARKER.*|[Download Latest Release](/download.html){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } <!-- VERSION-UPDATE-MARKER -->|" docs/index.md && rm docs/index.md.bak
sed -i.bak "s|Download\*\* the latest .dmg file from \[Download Page\](/download.html).*VERSION-UPDATE-MARKER.*|Download** the latest .dmg file from [Download Page](/download.html) <!-- VERSION-UPDATE-MARKER -->|" docs/index.md && rm docs/index.md.bak

# Commit, tag, and push

git add README.md docs/download.md docs/index.md

git commit -m "Release $TAG and update DMG/ZIP links and version/date"
git tag "$TAG"
git push origin main --tags
