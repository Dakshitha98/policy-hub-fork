#!/bin/bash

# Prepare ZIP for a policy version
# Usage: ./prepare-zip.sh <policy> <version>

set -euo pipefail  # Exit on error, undefined vars, pipe failures

POLICY=$1
VERSION=$2

# Input validation
if [[ -z "$POLICY" || -z "$VERSION" ]]; then
  echo "Usage: $0 <policy> <version>" >&2
  exit 1
fi

# Validate policy name format (alphanumeric, hyphens, underscores)
if [[ ! "$POLICY" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Invalid policy name format: $POLICY" >&2
  exit 1
fi

# Validate version format (semantic versioning)
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version format: $VERSION (expected vX.Y.Z)" >&2
  exit 1
fi

SRC_DIR="policies/$POLICY/$VERSION/src"
POLICY_DIR="policies/$POLICY/$VERSION"
ZIP_FILE="$POLICY-$VERSION.zip"

if [[ ! -d "$POLICY_DIR" ]]; then
  echo "Policy directory $POLICY_DIR not found" >&2
  exit 1
fi

# Check for required files
REQUIRED_FILES=("metadata.json" "policy-definition.yaml")
REQUIRED_DIRS=("src" "docs")

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$POLICY_DIR/$file" ]]; then
    echo "Required file $file not found in $POLICY_DIR" >&2
    exit 1
  fi
done

for dir in "${REQUIRED_DIRS[@]}"; do
  if [[ ! -d "$POLICY_DIR/$dir" ]]; then
    echo "Required directory $dir not found in $POLICY_DIR" >&2
    exit 1
  fi
done

# Check for required files in src
if ! find "$SRC_DIR" -name "*.go" -type f | grep -q .; then
  echo "Warning: No Go files found in $SRC_DIR" >&2
fi

# Check for required docs files
REQUIRED_DOCS=("overview.md" "configuration.md" "examples.md")
for doc in "${REQUIRED_DOCS[@]}"; do
  if [[ ! -f "$POLICY_DIR/docs/$doc" ]]; then
    echo "Required documentation file docs/$doc not found in $POLICY_DIR" >&2
    exit 1
  fi
done

# Create ZIP with better error handling
cd "$POLICY_DIR"
if ! zip -r "../../$ZIP_FILE" . >/dev/null 2>&1; then
  echo "Failed to create ZIP file" >&2
  exit 1
fi

# Verify ZIP was created and is not empty
if [[ ! -f "../../$ZIP_FILE" ]]; then
  echo "ZIP file was not created" >&2
  exit 1
fi

if [[ ! -s "../../$ZIP_FILE" ]]; then
  echo "ZIP file is empty" >&2
  rm -f "../../$ZIP_FILE"
  exit 1
fi

echo "Created $ZIP_FILE successfully"