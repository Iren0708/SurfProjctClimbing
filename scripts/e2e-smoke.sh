#!/usr/bin/env bash
# E2E smoke: локальный API + сценарий клиента (MOB-17)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HEALTH_URL="${API_HEALTH_URL:-http://localhost:8080/health}"

cd "$ROOT"
echo "Starting docker compose..."
docker compose up -d --build

echo "Waiting for API at $HEALTH_URL ..."
for _ in $(seq 1 60); do
  if curl -sf "$HEALTH_URL" | grep -q '"status":"UP"'; then
    echo "API is UP"
    break
  fi
  sleep 3
done

curl -sf "$HEALTH_URL" | grep -q '"status":"UP"' || {
  echo "API did not become healthy within 3 minutes" >&2
  exit 1
}

export TEMP="${TEMP:-$ROOT/.tmp}"
export TMP="$TEMP"
mkdir -p "$TEMP"

cd "$ROOT/mobile"
flutter test test/e2e/api_smoke_test.dart --dart-define=RUN_E2E=true
