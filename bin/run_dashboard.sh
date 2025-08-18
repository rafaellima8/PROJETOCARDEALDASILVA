#!/usr/bin/env bash
set -euo pipefail
# vai para a raiz do projeto
cd "$(dirname "$0")/.."

# ativa venv se existir
if [ -d ".venv" ]; then
  # shellcheck disable=SC1091
  source ".venv/bin/activate"
fi

# defaults de ambiente (podem ser sobrescritos)
export APP_USER="${APP_USER:-admin}"
export APP_PASS="${APP_PASS:-admin}"
export TZ="${TZ:-America/Bahia}"
export PORT="${PORT:-8502}"

# executa usando o Python da venv
exec python -m streamlit run "dashboards/licitanow/Home.py" \
  --server.port "${PORT}" --server.headless true
