#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# ativa venv se existir
if [ -d ".venv" ]; then
  # shellcheck disable=SC1091
  source ".venv/bin/activate"
fi

# opção: roda pre-commit antes (não falha o run se lint quebrar)
pre-commit run --all-files --show-diff-on-failure || true

# chama o script oficial do bin
exec ./bin/run_dashboard.sh
