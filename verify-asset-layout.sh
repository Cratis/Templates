#!/usr/bin/env bash
set -euo pipefail

# Verifies that applications scaffolded from the Vite-based templates emit their
# build artifacts under a single `assets/` prefix inside wwwroot.
#
# Vite hashes every artifact name, so the emitted set changes on each build and
# can never be enumerated up front. Kept under `assets/`, `/assets/**` is a rule
# any reverse proxy, CDN or WAF can be given. Flattened into the wwwroot root -
# which is what `build.assetsDir: ''` does - there is no prefix left to write a
# rule against, and the failure surfaces only at deployment, as a blank page:
# `MapFallbackToFile` answers the browser's asset requests with index.html at
# HTTP 200 rather than failing them visibly. README.md carries the longer
# explanation.
#
# The checks read the emitted output rather than the vite config, so they hold
# however the layout is arrived at - including a `rollupOptions.output.*FileNames`
# override, which bypasses `assetsDir` entirely and which a config-level check on
# `assetsDir` alone would wave through. Setting `base` stays legitimate: it moves
# the prefix without flattening it.
#
# Usage:
#   ./verify-asset-layout.sh                 scaffold both templates and verify
#   ./verify-asset-layout.sh <app-dir>...    verify already-scaffolded apps
#
# An <app-dir> is the directory holding package.json and .frontend, and is built
# first if it has no wwwroot yet. CI passes the applications it has already
# generated so they are not scaffolded twice.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failures=0

# Set by scaffold_and_verify. Script-scoped rather than local to it, because the
# EXIT trap that removes it runs after that function's locals are gone. The trap
# is written as an `if` rather than `[[ ... ]] && ...` so it always ends on a
# successful command - a trap whose last command fails takes the script's exit
# code with it, and would report a passing run as a failure.
work_dir=""
trap 'if [[ -n "$work_dir" ]]; then rm -rf "$work_dir"; fi' EXIT

info() { printf '\n\033[1m%s\033[0m\n' "$*"; }
pass() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$*"; failures=$((failures + 1)); }
detail() { printf '        %s\n' "$@"; }

# Installs dependencies if needed and runs the frontend build. Returns non-zero
# rather than aborting, so one unbuildable application does not hide the verdict
# on the others.
build_frontend() {
    local app_dir="$1"
    local installed=0

    if [[ -d "$app_dir/node_modules" ]]; then
        installed=1
    elif command -v yarn >/dev/null 2>&1; then
        # The templates default to yarn, so try it first. Yarn 1 refuses to
        # install at all when any transitive package declares an engines range
        # the local Node misses, where npm only warns - a dependency concern
        # rather than an asset-layout one, and not worth failing this check
        # over. Fall back, and say so rather than switching silently.
        if (cd "$app_dir" && yarn install --silent); then
            installed=1
        else
            echo "  yarn install failed - falling back to npm"
        fi
    fi

    if [[ "$installed" -eq 0 ]]; then
        (cd "$app_dir" && npm install --no-audit --no-fund --silent) || return 1
    fi

    (cd "$app_dir" && npm run build) || return 1
}

# The wwwroot root may hold `assets/`, the generated index.html, and whatever
# `.frontend/public` contributes - Vite copies those verbatim to the outDir root
# by design, and their references are root-relative on purpose. Anything else at
# the root is a build artifact that escaped `assets/`.
allowed_root_entries() {
    local app_dir="$1"

    printf '%s\n' assets index.html
    if [[ -d "$app_dir/.frontend/public" ]]; then
        find "$app_dir/.frontend/public" -mindepth 1 -maxdepth 1 -exec basename {} \;
    fi
}

# Returns non-zero when assets/ is missing entirely, which makes the remaining
# checks meaningless.
check_assets_is_populated() {
    local wwwroot="$1"

    if [[ ! -d "$wwwroot/assets" ]]; then
        fail "wwwroot/assets does not exist - the build artifacts have nowhere to be addressed from"
        detail "wwwroot holds: $(ls -1 "$wwwroot" | tr '\n' ' ')"
        return 1
    fi

    local js_count css_count
    js_count="$(find "$wwwroot/assets" -maxdepth 1 -name '*.js' | wc -l | tr -d ' ')"
    css_count="$(find "$wwwroot/assets" -maxdepth 1 -name '*.css' | wc -l | tr -d ' ')"

    if [[ "$js_count" -eq 0 ]]; then
        fail "wwwroot/assets holds no JavaScript - it exists but the build did not target it"
    else
        pass "wwwroot/assets holds the build artifacts ($js_count js, $css_count css)"
    fi
}

check_root_holds_no_artifacts() {
    local app_dir="$1" wwwroot="$2"
    local allowed entry unexpected=()

    allowed="$(allowed_root_entries "$app_dir")"

    while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        if ! grep -Fxq "$entry" <<<"$allowed"; then
            unexpected+=("$entry")
        fi
    done < <(ls -1 "$wwwroot")

    if [[ ${#unexpected[@]} -eq 0 ]]; then
        pass "the wwwroot root holds only index.html and public/ content"
        return
    fi

    fail "${#unexpected[@]} build artifact(s) emitted at the wwwroot root, where no path rule can reach them:"
    detail "${unexpected[@]}"
    detail "Expected every hashed artifact under wwwroot/assets/ so that /assets/** is expressible." \
        "Check build.assetsDir and rollupOptions.output.*FileNames in .frontend/vite.config.ts"
}

# Checked per reference rather than "at least one", because a script tag and a
# stylesheet tag can disagree - only one of them has to escape for the page to be
# unservable behind a path rule. Matched as a path segment rather than anchored
# at the root, so that setting `base` stays legitimate. Tags for `public/`
# content, such as the favicon, are left alone: those are root-relative by design.
check_index_references_are_prefixed() {
    local wwwroot="$1"
    local bundled_refs ref bad_refs=()

    if [[ ! -f "$wwwroot/index.html" ]]; then
        fail "no index.html was emitted"
        return
    fi

    bundled_refs="$(grep -oE '<script[^>]+src="[^"]+"|<link[^>]+rel="stylesheet"[^>]*>' "$wwwroot/index.html" |
        grep -oE '(src|href)="[^"]+"' | sed -E 's/^(src|href)="//; s/"$//' || true)"

    if [[ -z "$bundled_refs" ]]; then
        fail "index.html has no bundled script or stylesheet references at all"
        return
    fi

    while IFS= read -r ref; do
        [[ -z "$ref" ]] && continue
        [[ "$ref" == *assets/* ]] && continue
        bad_refs+=("$ref")
    done <<<"$bundled_refs"

    if [[ ${#bad_refs[@]} -eq 0 ]]; then
        pass "every bundled reference in index.html resolves under an assets/ segment"
    else
        fail "${#bad_refs[@]} of index.html's bundled reference(s) carry no assets/ prefix to rule on:"
        detail "${bad_refs[@]}"
    fi
}

verify_app() {
    local app_dir="$1" wwwroot="$1/wwwroot"

    info "Verifying $(basename "$app_dir") ($app_dir)"

    if [[ ! -f "$app_dir/package.json" || ! -d "$app_dir/.frontend" ]]; then
        fail "not a frontend application - no package.json or .frontend"
        return
    fi

    if [[ -d "$wwwroot" ]]; then
        echo "  wwwroot already present - verifying that build, not a fresh one"
    else
        echo "  building frontend..."
        if ! build_frontend "$app_dir" || [[ ! -d "$wwwroot" ]]; then
            fail "the frontend build failed - the asset layout could not be checked"
            return
        fi
    fi

    # `return 0`, not a bare `return`: a non-zero return from here would abort the
    # whole run under `set -e` and skip the applications after this one.
    check_assets_is_populated "$wwwroot" || return 0
    check_root_holds_no_artifacts "$app_dir" "$wwwroot"
    check_index_references_are_prefixed "$wwwroot"
}

scaffold() {
    local template="$1" name="$2" out="$3"
    shift 3

    # `--allow-scripts` is only a recognised option for templates that declare a
    # run-script post-action, and whether a given template does is not fixed -
    # it changes as templates evolve. Where it is recognised it is also needed:
    # with stdin closed, as under CI, dotnet new reads EOF at the approval
    # prompt, rejects it as invalid input and asks again forever rather than
    # failing. Where it is not recognised, passing it is a hard error. So ask
    # the template which of the two it is rather than assuming.
    local approval=()
    if dotnet new "$template" -h 2>/dev/null | grep -q -- '--allow-scripts'; then
        approval=(--allow-scripts Yes)
    fi

    echo "  $template -> $name"
    if ! dotnet new "$template" -n "$name" -o "$out" ${approval[@]+"${approval[@]}"} "$@" >"$out.scaffold.log" 2>&1; then
        fail "dotnet new $template failed"
        sed 's/^/        /' "$out.scaffold.log" | tail -20
        return 1
    fi
}

# The Cratis proxy generator rewrites the TypeScript proxies in place during
# `dotnet build` (CratisProxiesOutputPath points at the project itself). A
# frontend built without that step compiles the template's placeholder proxies
# rather than the generated ones, which is a weaker check than CI performs -
# CI builds the backend first. Build here too, so a standalone run and a CI run
# agree about what they verified.
build_backend() {
    local project_root="$1" solution

    solution="$(find "$project_root" -maxdepth 1 -name '*.sln' | head -n 1)"
    [[ -z "$solution" ]] && return 0

    if ! dotnet build "$solution" --configuration Release >"$project_root.build.log" 2>&1; then
        fail "dotnet build failed for $(basename "$project_root") - proxies were not generated"
        sed 's/^/        /' "$project_root.build.log" | tail -15
        return 1
    fi
}

scaffold_and_verify() {
    work_dir="$(mktemp -d)"

    info "Refreshing locally installed templates from $repo_root"
    "$repo_root/install-local.sh" >/dev/null

    info "Scaffolding into $work_dir"
    # Post-action approval is handled inside scaffold(). `--packageManager none`
    # keeps the cratis template from installing frontend dependencies, which it
    # would otherwise do differently from the Aspire template - that one has no
    # packageManager symbol. Both arrive here without dependencies and
    # build_frontend installs what they need, the same way for each.
    scaffold cratis VerifyCratis "$work_dir/VerifyCratis" --packageManager none || return 0
    scaffold cratis-aspire VerifyCratisAspire "$work_dir/VerifyCratisAspire" || return 0

    info "Building backends so the TypeScript proxies are generated"
    build_backend "$work_dir/VerifyCratis" || return 0
    build_backend "$work_dir/VerifyCratisAspire" || return 0

    local app_dir
    while IFS= read -r app_dir; do
        verify_app "$app_dir"
    done < <(find "$work_dir" -type d -name .frontend -not -path '*/node_modules/*' -exec dirname {} \; | sort)
}

if [[ $# -gt 0 ]]; then
    for app in "$@"; do
        verify_app "$(cd "$app" && pwd)"
    done
else
    scaffold_and_verify
fi

if [[ "$failures" -gt 0 ]]; then
    printf '\n\033[31mFAILED\033[0m - %s check(s) did not pass\n' "$failures"
    exit 1
fi

printf '\n\033[32mPASSED\033[0m - every scaffolded frontend serves its build artifacts from /assets/\n'
