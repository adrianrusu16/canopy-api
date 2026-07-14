#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

shopt -s nullglob
contract_docs=(README.md docs/*.md proto/canopy/v1/*.proto)

forbidden='PandaEngine|CANOPY_[A-Z0-9_]+|secrets\.[A-Z0-9_]+|/internal/stream/authorize|/nginx-health|PostgreSQL session recheck|SMTP delivery'

if grep -En "$forbidden" "${contract_docs[@]}"; then
  echo "product-specific or implementation-specific content found in contract documentation" >&2
  exit 1
fi

if [[ -e openapi/openapi.json ]]; then
  echo "mixed OpenAPI companion must not live in the contract repository" >&2
  exit 1
fi
