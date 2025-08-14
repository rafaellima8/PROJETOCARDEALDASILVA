#!/usr/bin/env bash
set -euo pipefail

# ir para a raiz do repo (se estiver em um subdir)
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  cd "$(git rev-parse --show-toplevel)"
fi

echo "== [1/5] harden .gitignore ==";
touch .gitignore
while read -r p; do grep -qxF "$p" .gitignore || echo "$p" >> .gitignore; done <<EOF_IGN
.venv/
.streamlit/
data/
vendor/
vendors/priceAPI/data/
backups/
resultados/
logs/
__pycache__/
*.sqlite
*.db
*.parquet
*.zip
*.gz
*.xz
*.csv
*.xlsx
*.pyc
app.log*
EOF_IGN

echo "== [2/5] criar pastas ==";
mkdir -p services scripts utils data/reports

echo "== [3/5] services/model_store.py ==";
cat > services/model_store.py <<PY
from __future__ import annotations
from pathlib import Path
import joblib, json, time, os
from typing import Any, Dict, List

MODEL_BASE = Path("data/models")

def _ensure_base() -> None:
    MODEL_BASE.mkdir(parents=True, exist_ok=True)

def _auto_version() -> str:
    return time.strftime("v%Y%m%d_%H%M%S")

def save_model(model_name: str, model_obj: Any, feature_names: List[str] | None = None,
              target_col: str | None = None, version: str | None = None,
              extra_meta: Dict[str, Any] | None = None, train_metrics: Dict[str, Any] | None = None) -> Path:
    _ensure_base()
    version = version or _auto_version()
    mp = MODEL_BASE / model_name / version
    mp.mkdir(parents=True, exist_ok=True)
    model_file = mp / "model.joblib"
    joblib.dump(model_obj, model_file)

    meta = {"model_name": model_name, "version": version, "feature_names": feature_names,
            "target_col": target_col, "train_metrics": train_metrics}
    if extra_meta:
        if isinstance(extra_meta, dict): meta.update(extra_meta)
        else: meta["extra_meta"] = extra_meta
    with open(mp / "metadata.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    print(f"[MODEL] saved: {model_file}")
    return model_file

def list_model_paths() -> list[Path]:
    if not MODEL_BASE.exists(): return []
    return [p for p in MODEL_BASE.glob("*/*/model.joblib") if p.is_file()]

def load(path: str | os.PathLike) -> Any:
    return joblib.load(path)
PY

echo "== [4/5] scripts/report_monthly.py ==";
cat > scripts/report_monthly.py <<PY
#!/usr/bin/env python3
from pathlib import Path
import json
import pandas as pd

OUT = Path("data/reports"); OUT.mkdir(parents=True, exist_ok=True)

def load_kpis() -> dict:
    k = {}
    pncp = Path("data/processed/pncp_itens.csv")
    if pncp.exists():
        df = pd.read_csv(pncp)
        k["Registros PNCP"] = int(len(df))
        if "preco_unitario" in df.columns:
            try:
                k["Preço médio PNCP"] = round(float(pd.to_numeric(df["preco_unitario"], errors="coerce").mean()), 2)
            except Exception: pass
        for cand in ("item_id","codigo_item","codigo"):
            if cand in df.columns:
                try: k["Itens distintos"] = int(df[cand].nunique()); break
                except Exception: pass
    bench = Path("data/metrics/model_bench.json")
    if bench.exists():
        try:
            bj = json.loads(bench.read_text(encoding="utf-8"))
            for key in ("avg_mape_baseline","avg_mape_model","n_items"):
                if key in bj: k[key] = bj[key]
        except Exception: pass
    return k

def main():
    kpis = load_kpis()
    try:
        from utils.pdf import export_exec_report
        path = OUT / "relatorio_mensal.pdf"
        export_exec_report(str(path), kpis, notes="Relatório mensal automático: PNCP + modelos.")
        print(f"[REPORT] Gerado {path}")
    except Exception as e:
        path = OUT / "relatorio_mensal.md"
        lines = ["# Relatório Mensal",""] + [f"- {k}: {v}" for k, v in kpis.items()]
        path.write_text("\\n".join(lines), encoding="utf-8")
        print(f"[REPORT] (fallback) Gerado {path} | Motivo PDF: {e}")

if __name__ == "__main__":
    main()
PY
chmod +x scripts/report_monthly.py

echo "== [5/5] scripts/run_data_pipelines.sh ==";
cat > scripts/run_data_pipelines.sh <<SH
#!/usr/bin/env bash
set -e
echo "[INFO] Running lightweight PNCP/SINAPI validation..."
if [ -f "scripts/validate_data.py" ]; then
  python3 scripts/validate_data.py || true
else
  echo "[SKIP] scripts/validate_data.py não encontrado."
fi
SH
chmod +x scripts/run_data_pipelines.sh

# utils/config.py mínimo com settings
mkdir -p utils
if [ ! -f utils/config.py ]; then
  printf "%s\n" "class _Settings: pass" "settings = _Settings()" > utils/config.py
elif ! grep -Eq "^[[:space:]]*settings[[:space:]]*=" utils/config.py; then
  printf "\\nclass _Settings: pass\\nsettings = _Settings()\\n" >> utils/config.py
fi

# commit opcional (só se estiver em repo Git)
if git rev-parse --git-dir >/dev/null 2>&1; then
  git add .gitignore services/model_store.py scripts/report_monthly.py scripts/run_data_pipelines.sh utils/config.py 2>/dev/null || true
  git commit -m "chore: fix model_store + report_monthly + pipelines leves + settings minimo" 2>/dev/null || true
fi

echo
echo "== Feito. Próximos passos ==";
echo "bash scripts/run_data_pipelines.sh"
echo "python3 scripts/train_models.py   || true"
echo "python3 scripts/bench_models.py   || true"
echo "python3 scripts/report_monthly.py || true"
echo "pytest -q                         || true"
