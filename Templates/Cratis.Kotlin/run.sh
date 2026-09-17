#!/usr/bin/env bash
# Run the scaffolded application end to end — Chronicle kernel, backend, and frontend.
#
# Usage:
#   ./run.sh                  # start infrastructure, run the backend + frontend dev server
#   ./run.sh --no-frontend    # backend only, for curl
#
# Everything this starts is stopped again on exit, including the Docker containers.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

NO_FRONTEND=false
for arg in "$@"; do
  case "$arg" in
    --no-frontend) NO_FRONTEND=true ;;
    *) echo "Unknown option: $arg (supported: --no-frontend)"; exit 2 ;;
  esac
done

command -v docker >/dev/null || { echo "docker is required (docker-compose runs the Chronicle kernel)"; exit 2; }
command -v java >/dev/null || { echo "JDK 17 is required (./gradlew bootRun runs the backend)"; exit 2; }

cleanup() {
  if [ "$NO_FRONTEND" = false ] && [ -n "${FRONTEND_PID:-}" ]; then
    kill "$FRONTEND_PID" 2>/dev/null || true
  fi
  docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "==> Starting the Chronicle kernel (docker compose)…"
docker compose up -d 2>/dev/null || docker-compose up -d

echo "==> Building the backend (also generates the frontend proxies)…"
./gradlew --quiet build

if [ "$NO_FRONTEND" = false ] && [ -f package.json ]; then
  echo "==> Installing frontend dependencies…"
  yarn install --silent 2>/dev/null || npm install --silent
  echo "==> Starting the frontend dev server on http://localhost:5173…"
  (yarn dev 2>/dev/null || npm run dev) &
  FRONTEND_PID=$!
fi

echo "==> Starting the backend on http://localhost:8080 (Ctrl+C stops everything)…"
./gradlew --quiet bootRun
