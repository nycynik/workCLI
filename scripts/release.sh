#!/usr/bin/env bash
set -euo pipefail

# Release script for workcli

# if no version, quit
if [ -z "${1:-}" ]; then
    echo "No version specified, quitting."
    exit 1
fi

VERSION="$1"

# 1. Update version in code
echo "Updating version to $VERSION --"
sed -i '' "s/^VERSION=.*/VERSION=\"$VERSION\"/" lib/core.sh
bin/workcli --version
echo "Version updated to $VERSION"

# 2. Commit and tag
echo "Committing changes and tagging version $VERSION --"
git add lib/core.sh
git commit -m "Bump version to $VERSION"
git tag "v$VERSION"
git push origin main --tags
echo "Changes committed and tagged version $VERSION"

# 3. Get archive URL and sha
echo "Getting archive URL and SHA for version $VERSION --"
ARCHIVE_URL="https://github.com/nycynik/workcli/archive/refs/tags/v$VERSION.tar.gz"
SHA=$(curl -L "$ARCHIVE_URL" | shasum -a 256 | awk '{print $1}')
echo "Updated sha to $SHA"

echo "moving to homebrew-workcli"
cd ../homebrew-workcli

# 4. Update tap formula
echo "Updating the Homebrew formula --"
sed -i '' "s|url .*|url \"$ARCHIVE_URL\"|" workcli.rb
sed -i '' "s|sha256 .*|sha256 \"$SHA\"|" workcli.rb

# 5. Commit formula update
echo "Committing formula update --"
git add workcli.rb
git commit -m "Bump workcli to $VERSION"
git push

# return to original directory
cd -

echo "Formula update complete!"