#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:-finance_miniapp}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql not found. Install PostgreSQL first." >&2
  exit 1
fi

createdb "$DB_NAME" 2>/dev/null || true
psql -d "$DB_NAME" -f "$(dirname "$0")/schema.sql"
psql -d "$DB_NAME" -f "$(dirname "$0")/seed.sql"

echo "Database '$DB_NAME' is ready."
