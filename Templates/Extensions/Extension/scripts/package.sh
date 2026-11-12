#!/usr/bin/env bash
# Lays the package out as it ships, in dist/extension: the contract, what it declares and the built parts.
# Run scripts/build.sh first.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$root"

rm -rf dist/extension
mkdir -p dist/extension
cp contract.play dist/extension/
for part in assets placeholders frontend backend ui; do
    if [[ -d "$part" ]]; then
        cp -R "$part" dist/extension/
    fi
done

echo "Laid out dist/extension."
