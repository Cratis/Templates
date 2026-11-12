#!/usr/bin/env bash
# Runs the specifications of every part of the extension.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$root"

if [[ -d src/backend-csharp ]]; then
    dotnet test src/backend-csharp/ExtensionName.slnx
fi

if [[ -d src/backend-kotlin ]]; then
    (cd src/backend-kotlin && ./gradlew test)
fi

if [[ -d src/backend-go ]]; then
    go_prepare src/backend-go
    (cd src/backend-go && go vet ./... && go test ./...)
fi

if [[ -d src/backend-typescript ]]; then
    npm_install src/backend-typescript
    (cd src/backend-typescript && npm run typecheck && npm test)
fi

for frontend in src/frontend-react src/frontend-mount; do
    if [[ -d "$frontend" ]]; then
        npm_install "$frontend"
        (cd "$frontend" && npm run typecheck && npm test)
    fi
done

echo "The specifications of ExtensionName passed."
