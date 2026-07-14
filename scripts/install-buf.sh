#!/usr/bin/env bash
set -euo pipefail

version="1.71.0"
sha256="d3de2838c68a5759ca276884254bc70df4e4ad185d6ed5f65f327b6ce6363eab"
asset="buf-Linux-x86_64"
install_root="${RUNNER_TEMP:?RUNNER_TEMP must be set}/buf-${version}"
binary="${install_root}/buf"

mkdir -p "$install_root"
curl \
  --fail \
  --location \
  --proto '=https' \
  --retry 3 \
  --show-error \
  --silent \
  --tlsv1.2 \
  --output "$binary" \
  "https://github.com/bufbuild/buf/releases/download/v${version}/${asset}"

printf '%s  %s\n' "$sha256" "$binary" | sha256sum --check --status
chmod 0755 "$binary"
printf '%s\n' "$install_root" >>"${GITHUB_PATH:?GITHUB_PATH must be set}"
