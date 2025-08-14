#!/usr/bin/env bash
set -e
echo "[INFO] Running lightweight PNCP/SINAPI validation..."
if [ -f "scripts/validate_data.py" ]; then
  python3 scripts/validate_data.py || true
else
  echo "[SKIP] scripts/validate_data.py não encontrado."
fi
