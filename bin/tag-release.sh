#!/bin/bash
# tag-release.sh: Tag and push a new release, or show the latest tag if no argument is given.
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

git add .
git commit -m "Release $TAG"
git tag "$TAG"
git push origin main --tags
