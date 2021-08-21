#! /usr/bin/env bash

set -ex

REPO_DIR="$PWD"

pushd /tmp/crate-index

# Add crates to the index
if ! command -v cargo-index; then
    echo "cargo-index is not installed. See https://doc.rust-lang.org/cargo/reference/registries.html#index-format how to update your index manually"
else
    for file in $(git --git-dir "$REPO_DIR"/.git --work-tree="$REPO_DIR" diff HEAD~1 --diff-filter=A --name-only); do
        cargo-index index add --index . --crate "$REPO_DIR/$file" --index-url=$(git remote get-url origin) 
    done
fi

# Remove crates from the index
if ! command -v python; then
    echo "python is not installed. Deleting packages automatically requires perl to be installed"
else
    for file in $(git --git-dir "$REPO_DIR"/.git --work-tree="$REPO_DIR" diff HEAD~1 --diff-filter=D --name-only); do
        read crate_name crate_version <<< $(sed -nr "s/([A-Za-z_][A-Za-z0-9_\-]*)\-([0-9]\..*)\.crate/\1\n\2/p" <<< "$file")
        cargo-index index yank --index . --package "$crate_name" --version "$crate_version"
    done
fi

# You may have to configure git before the script is executed or do this in a separate step
git push

popd
