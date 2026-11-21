#!/usr/bin/env bash
# Copyright (c) Cratis. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
set -euo pipefail

# Check that a scaffolded cratis-aspire solution takes its telemetry from the shared
# Cratis.OpenTelemetry setup: no direct OpenTelemetry references, concrete resolved
# versions, and a Cratis span captured in memory from the scaffolded Register command.
# Test-only dependencies live in a separate runner, never in a shipped template.
# Usage: Verification/Telemetry/verify-telemetry.sh <scaffolded-aspire-solution-directory>...
# Each directory holds <Name>/<Name>.csproj and <Name>.Infrastructure/; run after a restore.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <scaffolded-aspire-solution-directory>..." >&2
    exit 1
fi

mkdir -p "$repo_root/.ai-work"
work_dir="$(mktemp -d "$repo_root/.ai-work/telemetry.XXXXXX")"
echo "Telemetry verification artifacts: $work_dir"

index=0
for solution in "$@"; do
    solution="$(cd "$solution" && pwd)"
    runner="$work_dir/$index"
    # Prints the application project the runner references once the static checks pass.
    project="$(node "$repo_root/Verification/Telemetry/prepare-runner.mjs" "$solution" "$runner" "$repo_root")"
    dotnet run --project "$runner/Telemetry.csproj" --configuration Debug -p:CratisProxiesOutputPath=
    echo "Checked telemetry for $project"
    index=$((index + 1))
done
