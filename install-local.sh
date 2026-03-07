#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Refresh locally installed templates from this repo

dotnet new uninstall "$repo_root" <<< "y" || true

dotnet new install "$repo_root" --force <<< "y"
