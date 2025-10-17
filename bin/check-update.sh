#!/usr/bin/env bash
# bin/check-update.sh
# Check for a newer release using GitHub Releases and jq.
# Exit codes: 0 = update available, 1 = up-to-date, 2 = error


set -euo pipefail

REPO="literatecomputing/name-my-pdf"
API_LATEST="https://api.github.com/repos/${REPO}/releases/latest"

# Helper: find jq (prefer a bundled jq next to this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -x "$SCRIPT_DIR/../bundled-bin/jq" ]; then
  JQ_CMD="$SCRIPT_DIR/../bundled-bin/jq"
elif [ -x "$SCRIPT_DIR/bundled-bin/jq" ]; then
  JQ_CMD="$SCRIPT_DIR/bundled-bin/jq"
else
  JQ_CMD="jq"
fi
# Determine local version: prefer $VERSION env, else parse app_launcher.sh default,
# if that yields a placeholder or non-semver value, fall back to the most recent git tag.
if [ -n "${VERSION:-}" ]; then
  LOCAL_VERSION="$VERSION"
else
  if [ -f "app_launcher.sh" ]; then
    # Parse the default placeholder form: VERSION="${VERSION:-VERSION_PLACEHOLDER}"
    LOCAL_VERSION=$(sed -nE 's/^VERSION="\$\{VERSION:-([^}]*)\}"/\1/p' app_launcher.sh || true)
  fi
fi

# If we didn't find a usable version (placeholder or empty), fall back to latest git tag
if [ -z "${LOCAL_VERSION:-}" ] || echo "$LOCAL_VERSION" | grep -qEi 'placeholder|^\s*$|^VERSION_PLACEHOLDER$'; then
  if git rev-parse --git-dir > /dev/null 2>&1; then
    GITTAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
    if [ -n "$GITTAG" ]; then
      LOCAL_VERSION="$GITTAG"
    fi
  fi
fi

LOCAL_VERSION=${LOCAL_VERSION:-v0.0.0}

echo "Local version: $LOCAL_VERSION"

# Fetch latest release (non-prerelease) using the Releases API (/latest is non-prerelease)
if ! latest_json=$(curl -fsS "$API_LATEST"); then
  echo "Error: failed to fetch release data from GitHub API" >&2
  exit 2
fi

latest_tag=$(echo "$latest_json" | $JQ_CMD -r '.tag_name // empty') || latest_tag=""
latest_name=$(echo "$latest_json" | $JQ_CMD -r '.name // empty')
html_url=$(echo "$latest_json" | $JQ_CMD -r '.html_url // empty')

# If caller asked for just the latest info, print compact JSON and exit
if [ "${1:-}" = "--latest" ]; then
  # Use the jq we found to produce minimal JSON
  echo "$latest_json" | $JQ_CMD -c '{tag: .tag_name, url: .html_url, name: .name}'
  exit 0
fi

if [ -z "$latest_tag" ]; then
  echo "Error: could not parse latest tag from GitHub response" >&2
  exit 2
fi

echo "Latest release: $latest_tag ${latest_name:+($latest_name)}"

# Semantic version compare (strip leading v)
strip_v() { echo "$1" | sed 's/^v//'; }
to_parts() { IFS=. read -r a b c <<<"$1"; echo ${a:-0} ${b:-0} ${c:-0}; }

lv=$(strip_v "$LOCAL_VERSION")
rv=$(strip_v "$latest_tag")
read -r la lb lc <<<"$(to_parts "$lv")"
read -r ra rb rc <<<"$(to_parts "$rv")"

if [ "$ra" -gt "$la" ] || { [ "$ra" -eq "$la" ] && [ "$rb" -gt "$lb" ]; } || { [ "$ra" -eq "$la" ] && [ "$rb" -eq "$lb" ] && [ "$rc" -gt "$lc" ]; }; then
  echo "Update available: $latest_tag — $html_url"
  exit 0
else
  echo "Up to date: $LOCAL_VERSION"
  exit 1
fi
