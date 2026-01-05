#!/usr/bin/env bash
set -e

set -euo pipefail

FILE="extras/version.lua"

# Extract current version
VERSION=$(sed -n 's/.*version *= *\([0-9]\+\).*/\1/p' "$FILE")

if [[ -z "$VERSION" ]]; then
  echo "Error: version not found in $FILE"
  exit 1
fi

NEW_VERSION=$((VERSION + 1))

# Replace version in file
sed -i.bak "s/version *= *$VERSION/version = $NEW_VERSION/" "$FILE"

rm -f "$FILE.bak"

git add extras/version.lua
