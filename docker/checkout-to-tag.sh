#!/bin/bash -x
export PATH="$PATH:$DEPOT_TOOLS_ROOT"
#TAG=${1:-"81.0.4020.0"}
TAG=${1:-"87.0.4280.66"}

set -euo pipefail

cd $CHROMIUM_SRC_ROOT || exit 1

echo "checking out to tag $TAG"

# Git will preserve directories with their own Git repositories;
# bypass this by passing the --force option twice to git clean.
git clean -ffd
git fetch origin "refs/tags/$TAG:refs/tags/$TAG" --verbose
git checkout -B "$TAG" "tags/$TAG"

git clean -ffd
gclient sync -D --force --reset --with_branch_heads --with_tags

echo "Updated Chromium source to $TAG"

