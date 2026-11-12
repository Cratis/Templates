#!/usr/bin/env bash
set -euo pipefail

# Builds the extension SDKs that are not on their registries yet, so the generated packages can be built and tested.
#
# Usage: build-local-sdks.sh <work-folder>
#
# Prints NAME=VALUE lines on stdout, for `>> "$GITHUB_ENV"` or `export`; everything else goes to stderr:
#   CRATIS_STAGE_SDK  A clone of Cratis/Stage whose TypeScript SDK is built. Printed when any of the Kotlin, Go or TypeScript
#                     backend SDKs is not published.
#   CRATIS_SCENE_SDK  The @cratis/scene.extensions package as a tarball. Printed when it is not published.
#
# When an SDK is published the generated packages use the registry, so this script never hides a published SDK that does
# not work: it prints nothing for it.

work="${1:?Usage: build-local-sdks.sh <work-folder>}"
mkdir -p "$work"
work="$(cd "$work" && pwd)"

log() { echo "$*" >&2; }

published_npm() { npm view "$1" version > /dev/null 2>&1; }
published_maven() { curl --fail --silent --head "https://repo1.maven.org/maven2/io/cratis/stage/stage-extensions/maven-metadata.xml" > /dev/null; }
published_go() {
    local versions
    versions="$(curl --fail --silent "https://proxy.golang.org/github.com/!cratis/!stage/source/extensions/!go/@v/list" || true)"
    [[ -n "$versions" ]]
}

stage_needed=0
published_maven || { log "io.cratis.stage:stage-extensions is not on Maven Central: using a Stage clone."; stage_needed=1; }
published_go || { log "The Go extensions SDK has no release tag: using a Stage clone."; stage_needed=1; }
published_npm "@cratis/stage-extensions" || { log "@cratis/stage-extensions is not on npm: using a Stage clone."; stage_needed=1; }

if [[ "$stage_needed" -eq 1 ]]; then
    stage="$work/Stage"
    if [[ ! -d "$stage/.git" ]]; then
        git clone --quiet --depth 1 https://github.com/Cratis/Stage.git "$stage" >&2
    fi
    (cd "$stage/Source/Extensions/TypeScript" && npm ci >&2 && npm run build >&2)
    echo "CRATIS_STAGE_SDK=$stage"
fi

if ! published_npm "@cratis/scene.extensions"; then
    log "@cratis/scene.extensions is not on npm: building it from a Scene clone."
    scene="$work/Scene"
    if [[ ! -d "$scene/.git" ]]; then
        git clone --quiet --depth 1 https://github.com/Cratis/Scene.git "$scene" >&2
    fi

    # The package has no runtime dependency, so it is built outside Scene's yarn workspace: type declarations from tsc and
    # one ES module from esbuild, with React left external as the host provides it.
    package="$work/scene-extensions"
    rm -rf "$package"
    mkdir -p "$package"
    (cd "$scene/Source/JavaScript/extensions" && find . -maxdepth 1 -name '*.ts' ! -name '*.d.ts' -exec cp {} "$package/" \;)
    cat > "$package/package.json" <<'JSON'
{
    "name": "@cratis/scene.extensions",
    "version": "1.0.0",
    "type": "module",
    "main": "dist/index.js",
    "types": "dist/index.d.ts",
    "exports": { ".": { "types": "./dist/index.d.ts", "default": "./dist/index.js" } },
    "files": [ "dist" ],
    "peerDependencies": { "react": "^18.0.0 || ^19.0.0", "react-dom": "^18.0.0 || ^19.0.0" }
}
JSON
    cat > "$package/tsconfig.json" <<'JSON'
{
    "compilerOptions": {
        "target": "ES2022", "module": "ESNext", "moduleResolution": "Bundler", "declaration": true, "outDir": "dist",
        "strict": true, "skipLibCheck": true, "lib": ["ES2022", "DOM"], "jsx": "react-jsx"
    },
    "include": ["*.ts"]
}
JSON
    (
        cd "$package"
        rm -f vite.config.mts
        npm install --no-save typescript esbuild @types/react @types/react-dom react react-dom >&2
        npx tsc -p . --emitDeclarationOnly >&2
        npx esbuild index.ts --bundle --format=esm --target=es2022 --external:react --external:react-dom --jsx=automatic --outfile=dist/index.js >&2
        rm -rf node_modules
        npm pack --silent >&2
    )
    echo "CRATIS_SCENE_SDK=$(ls "$package"/*.tgz)"
fi
