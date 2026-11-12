#!/usr/bin/env bash
# Builds every part of the extension into the folders contract.play names: backend/ and frontend/.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$root"

if [[ -d src/backend-csharp ]]; then
    dotnet publish src/backend-csharp/ExtensionName/ExtensionName.csproj -c Release -o backend
fi

if [[ -d src/backend-kotlin ]]; then
    (cd src/backend-kotlin && ./gradlew shadowJar)
fi

if [[ -d src/backend-go ]]; then
    go_prepare src/backend-go
    # go build refuses to replace a file that is not a binary, which is what the placeholder is.
    rm -f backend/ExtensionName
    (cd src/backend-go && go build -o ../../backend/ExtensionName .)
fi

if [[ -d src/backend-typescript ]]; then
    npm_install src/backend-typescript
    (cd src/backend-typescript && npm run build)
fi

for frontend in src/frontend-react src/frontend-mount; do
    if [[ -d "$frontend" ]]; then
        npm_install "$frontend"
        (cd "$frontend" && npm run build)
    fi
done

echo "Built ExtensionName."
