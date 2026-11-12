#!/usr/bin/env bash
# Holds the package folder to what contract.play declares. Needs the Cratis CLI: https://github.com/Cratis/cli
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

cratis extension verify .
