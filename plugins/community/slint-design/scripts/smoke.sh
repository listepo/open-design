#!/usr/bin/env bash
# Smoke: slint-viewer --check on plugin examples and templates.
# Primary acceptance runtime for the skill is OpenCode under OpenDesign;
# this script only validates .slint compile diagnostics.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VIEWER="${SLINT_VIEWER:-slint-viewer}"

if ! command -v "$VIEWER" >/dev/null 2>&1; then
  echo "error: slint-viewer not found on PATH (set SLINT_VIEWER=...)" >&2
  exit 127
fi

echo "==> $($VIEWER --version 2>/dev/null || echo unknown)"

files=(
  "$ROOT/examples/hello-window.slint"
  "$ROOT/templates/desktop-window/ui.slint"
  "$ROOT/templates/settings-form/ui.slint"
)

failed=0
for f in "${files[@]}"; do
  echo "==> --check $f"
  if ! "$VIEWER" --check "$f"; then
    echo "FAIL: $f" >&2
    failed=1
  else
    echo "OK: $f"
  fi
done

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

echo "All smoke checks passed."
