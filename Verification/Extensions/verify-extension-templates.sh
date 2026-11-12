#!/usr/bin/env bash
set -euo pipefail

# Holds the extension templates to what `cratis extension new` and `cratis extension verify` agree on.
#
# Modes:
#   generate                       Create every combination of the two templates with the Cratis CLI and with
#                                  `dotnet new`, require both engines to create the same files, and require every
#                                  package to pass `cratis extension verify` without edits.
#   build <backend> <frontend>     Create one full extension and run its own scripts: test, build, package, then
#                                  verify the folder again as it ships. Backend: csharp|kotlin|go|typescript|none.
#                                  Frontend: react|mount|screenplay|none.
#   build-package <component>      The same for a frontend-only package. Component: react|mount.
#
# Environment:
#   CRATIS               The command that runs the Cratis CLI (default: cratis). It needs `extension new` and
#                        `extension verify`.
#   CRATIS_STAGE_SDK     A clone of Cratis/Stage, for the SDKs that are not published yet (see sdks.sh).
#   CRATIS_SCENE_SDK     The @cratis/scene.extensions tarball, for the same reason.
#   KEEP                 Set to keep the generated folders and print where they are.
#
# Every phase prints how many packages it examined, and the script exits 1 when any check failed, 2 when it could not run.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
templates="$repo_root/Templates/Extensions"
cratis_command="${CRATIS:-cratis}"

backends=(csharp kotlin go typescript none)
frontends=(react mount screenplay none)
components=(react mount)

work_dir="$(mktemp -d)"
cleanup() {
    if [[ -n "${KEEP:-}" ]]; then
        echo "Kept $work_dir"
    else
        rm -rf "$work_dir"
    fi
}
trap cleanup EXIT

failures=0
examined=0

info() { printf '\n\033[1m%s\033[0m\n' "$*"; }
pass() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
fail() {
    printf '  \033[31m✗\033[0m %s\n' "$*"
    failures=$((failures + 1))
}

run_cratis() { $cratis_command "$@"; }

# Creates a package with the Cratis CLI. Arguments: kind output-folder name then the choices as flags.
create_with_cli() {
    local output="$1"
    shift
    run_cratis extension new --template-path "$templates" --no-prompts -o "$output" \
        --display-name 'Sample "display" name' --description 'What the \sample does' --publisher acme "$@" > "$output.log" 2>&1
}

# Creates the same package with dotnet new.
create_with_dotnet() {
    local output="$1" short_name="$2" name="$3"
    shift 3
    dotnet new "$short_name" --debug:custom-hive "$work_dir/hive" -n "$name" -o "$output" \
        --DisplayName 'Sample "display" name' --Description 'What the \sample does' --Publisher acme "$@" > "$output.log" 2>&1
}

verify_folder() {
    local folder="$1" label="$2"
    if run_cratis extension verify "$folder" > "$folder.verify.log" 2>&1; then
        examined=$((examined + 1))
        pass "$label passes cratis extension verify"
    else
        fail "$label does not pass cratis extension verify (see below)"
        sed 's/^/        /' "$folder.verify.log" | head -40
    fi
}

install_for_dotnet() {
    dotnet new install "$templates/Extension" --debug:custom-hive "$work_dir/hive" > "$work_dir/install.log" 2>&1
    dotnet new install "$templates/ExtensionPackage" --debug:custom-hive "$work_dir/hive" >> "$work_dir/install.log" 2>&1
}

# Both engines must create the same files with the same content.
compare_engines() {
    local cli_folder="$1" dotnet_folder="$2" label="$3"
    if diff -r --exclude='*.log' "$cli_folder" "$dotnet_folder" > "$work_dir/diff.log" 2>&1; then
        pass "$label is the same from the Cratis CLI and from dotnet new"
    else
        fail "$label differs between the Cratis CLI and dotnet new"
        head -20 "$work_dir/diff.log" | sed 's/^/        /'
    fi
}

require_files() {
    local folder="$1" label="$2"
    shift 2
    local missing=0
    for path in "$@"; do
        if [[ ! -e "$folder/$path" ]]; then
            fail "$label has no $path"
            missing=1
        fi
    done
    return $missing
}

generate_all() {
    install_for_dotnet
    mkdir -p "$work_dir/cli" "$work_dir/dotnet"

    info "Full extensions: every Backend x Frontend"
    for backend in "${backends[@]}"; do
        for frontend in "${frontends[@]}"; do
            local name="Sample" label="extension ($backend, $frontend)"
            local folder="$backend-$frontend"
            if ! create_with_cli "$work_dir/cli/$folder" -n "$name" --kind extension --backend "$backend" --frontend "$frontend"; then
                fail "$label was not created by the Cratis CLI"
                head -10 "$work_dir/cli/$folder.log" | sed 's/^/        /'
                continue
            fi
            create_with_dotnet "$work_dir/dotnet/$folder" cratis-extension "$name" --Backend "$backend" --Frontend "$frontend" \
                || fail "$label was not created by dotnet new"

            require_files "$work_dir/cli/$folder" "$label" contract.play .extensionignore README.md assets/icon.svg assets/marketplace.svg \
                scripts/build.sh scripts/test.sh scripts/package.sh scripts/publish.sh scripts/verify.sh Dockerfile || true
            verify_folder "$work_dir/cli/$folder" "$label"
            compare_engines "$work_dir/cli/$folder" "$work_dir/dotnet/$folder" "$label"
        done
    done

    info "Frontend-only packages: every Component"
    for component in "${components[@]}"; do
        local label="package ($component)" folder="package-$component"
        if ! create_with_cli "$work_dir/cli/$folder" -n Sample --kind package --component "$component"; then
            fail "$label was not created by the Cratis CLI"
            head -10 "$work_dir/cli/$folder.log" | sed 's/^/        /'
            continue
        fi
        create_with_dotnet "$work_dir/dotnet/$folder" cratis-extension-package Sample --Component "$component" \
            || fail "$label was not created by dotnet new"
        require_files "$work_dir/cli/$folder" "$label" contract.play .extensionignore README.md package.json assets/icon.svg assets/marketplace.svg dist/index.js || true
        verify_folder "$work_dir/cli/$folder" "$label"
        compare_engines "$work_dir/cli/$folder" "$work_dir/dotnet/$folder" "$label"
    done

    info "Screenplay components compile"
    local ui_checked=0
    for backend in "${backends[@]}"; do
        local folder="$work_dir/cli/$backend-screenplay"
        if run_cratis screenplay validate "$folder/ui" > "$folder.ui.log" 2>&1; then
            ui_checked=$((ui_checked + 1))
        else
            fail "ui/ of ($backend, screenplay) does not compile"
            head -10 "$folder.ui.log" | sed 's/^/        /'
        fi
    done
    pass "$ui_checked Screenplay component folders compile"
}

build_extension() {
    local backend="$1" frontend="$2"
    local folder="$work_dir/$backend-$frontend"
    local label="extension ($backend, $frontend)"
    info "Build and test $label"
    create_with_cli "$folder" -n Sample --kind extension --backend "$backend" --frontend "$frontend"
    (cd "$folder" && chmod +x scripts/*.sh && scripts/test.sh && scripts/build.sh && scripts/package.sh) > "$work_dir/build.log" 2>&1 \
        && pass "$label tests, builds and packages" \
        || { fail "$label did not build"; tail -40 "$work_dir/build.log" | sed 's/^/        /'; return; }
    verify_folder "$folder" "$label as built"
    if [[ ! -f "$folder/dist/extension/contract.play" ]]; then
        fail "$label has no dist/extension/contract.play"
    else
        pass "$label lays out /extension/contract.play"
    fi
}

# Node-based scripts of the frontend-only package: npm only, so they are run here directly.
link_scene_sdk() {
    local folder="$1"
    if [[ -n "${CRATIS_SCENE_SDK:-}" ]]; then
        node "$templates/Extension/scripts/link-sdk.mjs" "$folder" "@cratis/scene.extensions" "$CRATIS_SCENE_SDK"
    fi
}

build_package() {
    local component="$1"
    local folder="$work_dir/package-$component"
    local label="package ($component)"
    info "Build and test $label"
    create_with_cli "$folder" -n Sample --kind package --component "$component"
    link_scene_sdk "$folder"
    (cd "$folder" && npm install && npm run typecheck && npm test && npm run build) > "$work_dir/build.log" 2>&1 \
        && pass "$label tests and builds" \
        || { fail "$label did not build"; tail -40 "$work_dir/build.log" | sed 's/^/        /'; return; }
    verify_folder "$folder" "$label as built"
}

mode="${1:-}"
case "$mode" in
    generate) generate_all ;;
    build) build_extension "${2:?backend}" "${3:?frontend}" ;;
    build-package) build_package "${2:?component}" ;;
    *)
        echo "Usage: $0 generate | build <backend> <frontend> | build-package <component>" >&2
        exit 2
        ;;
esac

echo
if [[ "$examined" -eq 0 && "$mode" == "generate" ]]; then
    echo "No package was examined: the run proves nothing." >&2
    exit 2
fi

if [[ "$failures" -ne 0 ]]; then
    echo "$failures check(s) failed ($examined package(s) verified)."
    exit 1
fi
echo "All checks passed ($examined package(s) verified)."
