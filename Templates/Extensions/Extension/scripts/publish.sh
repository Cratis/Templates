#!/usr/bin/env bash
# Builds, packages and publishes the extension as an OCI artifact: scripts/publish.sh <version>
# Needs docker and a login to the registry (docker login ghcr.io). Sign the pushed image as Stage's trust policy requires.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$root"

version="${1:?Usage: scripts/publish.sh <version>}"
image="ghcr.io/PUBLISHER/extension-EXTENSION_KEBAB:${version}"

scripts/build.sh
scripts/package.sh
docker build --tag "$image" .
docker push "$image"

echo "Published ${image}."
