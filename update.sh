#! /usr/bin/env bash

set -ex

if [ -z $1 ]; then
    echo "Usage: $0 /path/to/index/repository"
    exit 1
fi
if ! command -v cargo-index; then
    echo "cargo-index is not installed. See https://doc.rust-lang.org/cargo/reference/registries.html#index-format how to update your index manually"
    exit 1
fi

REPO_DIR="$PWD"

pushd $1

# Add crates to the index
for file in $(git --git-dir "$REPO_DIR"/.git --work-tree="$REPO_DIR" diff HEAD~1 --diff-filter=A --name-only); do
    if [[ $file != *.crate ]];then
        continue
    fi
    cargo-index index add --index . --crate "$REPO_DIR/$file" --index-url=$(git remote get-url origin) 
done

# Remove crates from the index
for file in $(git --git-dir "$REPO_DIR"/.git --work-tree="$REPO_DIR" diff HEAD~1 --diff-filter=D --name-only); do
    if [[ $file != *.crate ]];then
        continue
    fi
    crate_name=$(sed -nr "s/([A-Za-z_][A-Za-z0-9_\-]*)\-([0-9]\..*)\.crate/\1/p" <<< "$file")
    crate_version=$(sed -nr "s/([A-Za-z_][A-Za-z0-9_\-]*)\-([0-9]\..*)\.crate/\2/p" <<< "$file")
    cargo-index index yank --index . --package "$crate_name" --version "$crate_version"
done

# You may have to configure git before the script is executed or do this in a separate step
git push

popd
