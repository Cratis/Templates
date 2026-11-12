#!/usr/bin/env bash
# Shared by the build scripts. Source it; it does nothing on its own.
#
# The backend and frontend SDKs are resolved from their registries. Until they are published, point these at a local build:
#   CRATIS_STAGE_SDK  a clone of https://github.com/Cratis/Stage (Kotlin and Go use it as it is; for TypeScript, run
#                     `npm install && npm run build` in Source/Extensions/TypeScript first)
#   CRATIS_SCENE_SDK  the @cratis/scene.extensions package as a tarball (`npm pack` in Source/JavaScript/extensions of a
#                     https://github.com/Cratis/Scene clone)
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Installs the npm dependencies of a folder, using a local SDK build when one is set.
npm_install() {
    local folder="$1"
    if [[ -n "${CRATIS_STAGE_SDK:-}" ]]; then
        node "$root/scripts/link-sdk.mjs" "$folder" "@cratis/stage-extensions" "$CRATIS_STAGE_SDK/Source/Extensions/TypeScript"
    fi
    if [[ -n "${CRATIS_SCENE_SDK:-}" ]]; then
        node "$root/scripts/link-sdk.mjs" "$folder" "@cratis/scene.extensions" "$CRATIS_SCENE_SDK"
    fi
    (cd "$folder" && npm install)
}

# Resolves the Go module dependencies, using a local SDK build when one is set.
go_prepare() {
    local folder="$1"
    if [[ -n "${CRATIS_STAGE_SDK:-}" ]]; then
        (cd "$folder" && go mod edit -replace "github.com/Cratis/Stage/Source/Extensions/Go=$CRATIS_STAGE_SDK/Source/Extensions/Go")
    fi
    (cd "$folder" && go mod tidy)
}
