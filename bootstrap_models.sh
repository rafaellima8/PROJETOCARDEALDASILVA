#!/usr/bin/env bash
set -euo pipefail

# ir para a raiz do repo (se estiver em subdir)
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  cd "$(git rev-parse --show-toplevel)"
fi
mkdir -p scripts services utils data/{raw,processed,features,metrics,reports} >/dev/null 2>&1 || true

echo "== 1/7 .venv local e deps ==";
PYBIN="${PYBIN:-python3}"
if [ ! -x ".venv/bin/python" ]; then
  "$PYBIN" -m venv .venv
fi
. .venv/bin/activate
python -m pip install -U pip >/dev/null
touch requirements.txt
grep -q "^pandas" requirements.txt || echo "pandas>=2.0,<2.3" >> requirements.txt
grep -q "^scikit-learn" requirements.txt || echo "scikit-learn>=1.3,<1.6" >> requirements.txt
grep -q "^joblib" requirements.txt || echo "joblib>=1.3" >> requirements.txt
python -m pip install -r requirements.txt

echo "== 2/7 services/model_store.py (já existe do passo anterior) ==";
if [ ! -f services/model_store.py ]; then
  cat > services/model_store.py <<PY
from __future__ import annotations
from pathlib import Path
import joblib, json, time, os
from typing import Any, Dict, List

MODEL_BASE = Path("data/models")
def _ensure_base(): MODEL_BASE.mkdir(parents=True, exist_ok=True)
def _auto_version() -> str: return time.strftime("v%Y%m%d_%H%M%S")

def save_model(model_name: str, model_obj: Any, feature_names: List[str] | None = None,
              target_col: str | None = None, version: str | None = None,
              extra_meta: Dict[str, Any] | None = None, train_metrics: Dict[str, Any] | None = None) -> Path:
    _ensure_base(); version = version or _auto_version()
    mp = MODEL_BASE / model_name / version; mp.mkdir(parents=True, exist_ok=True)
    joblib.dump(model_obj, mp / "model.joblib")
    meta = {"model_name": model_name, "version": version, "feature_names": feature_names,
            "target_col": target_col, "train_metrics": train_metrics}
    if isinstance(extra_meta, dict): meta.update(extra_meta)
    with open(mp / "metadata.json", "w", encoding="utf-8") as f: json.dump(meta, f, ensure_ascii=False, indent=2)
    print(f"[MODEL] saved: {mp / "model.joblib"}"); return mp / "model.joblib"

def list_model_paths() -> list[Path]:
    if not MODEL_BASE.exists(): return []
    return [p for p in MODEL_BASE.glob("*/*/model.joblib") if p.is_file()]

def load(path: str | os.PathLike) -> Any: return joblib.load(path)
PY
fi

echo "== 3/7 utils/config.py mínimo (settings) ==";
mkdir -p utils
if [ ! -f utils/config.py ]; then
  printf "%s\n" "class _Settings: pass" "settings = _Settings()" > utils/config.py
elif ! grep -Eq "^[[:space:]]*settings[[:space:]]*=" utils/config.py; then
  printf "\\nclass _Settings: pass\\nsettings = _Settings()\\n" >> utils/config.py
fi

echo "== 4/7 scripts/train_models.py ==";
cat > scripts/train_models.py <<PY
#!/usr/bin/env python3
from pathlib import Path
import re, glob, json
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_absolute_percentage_error, r2_score
from services.model_store import save_model

DATA_DIR = Path("data")
PROC = DATA_DIR / "processed"; PROC.mkdir(parents=True, exist_ok=True)

def _slug(s: str) -> str:
    s = re.sub(r"[^0-9a-zA-Z_]+", "_", s).strip("_").lower();
    return re.sub("_+", "_", s)

def _gen_synth() -> Path:
    n = 800
    rng = np.random.default_rng(42)
    f1 = rng.normal(0, 1, n); f2 = rng.normal(5, 2, n); cat = rng.choice(["A","B","C"], n)
    y = 10 + 3*f1 + 0.7*f2 + (cat == "B")*2 + rng.normal(0, 1, n)
    df = pd.DataFrame({"feature1": f1, "feature2": f2, "categoria": cat, "target": y})
    path = PROC / "demo_sintetico.csv"; df.to_csv(path, index=False); return path

def find_csv() -> Path:
    pats = ["data/processed/*.csv","data/features/*.csv","data/raw/*.csv"]
    for p in pats:
        files = glob.glob(p);
        if files: return Path(sorted(files)[0])
    return _gen_synth()

def prep(df: pd.DataFrame):
    df = df.copy(); df.columns = [_slug(c) for c in df.columns]
    target = None
    for c in ["target","preco_unitario","valor","price","y"]:
        if c in df.columns: target = c; break
    if target is None:
        raise RuntimeError("Não encontrei coluna alvo (target/preco_unitario/valor/price/y).")
    for c in df.columns:
        if c == target: continue
        if df[c].dtype == "O": df[c] = df[c].astype("category").cat.codes
        if df[c].isna().any(): df[c] = df[c].fillna(df[c].median() if pd.api.types.is_numeric_dtype(df[c]) else 0)
    X = df.drop(columns=[target]); y = df[target].astype(float)
    return X, y, target, list(X.columns)

def main():
    path = find_csv(); print(f"[INFO] dataset: {path}")
    df = pd.read_csv(path, low_memory=False)
    X, y, target, feats = prep(df)
    Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=42)
    model = RandomForestRegressor(n_estimators=200, random_state=42, n_jobs=-1)
    model.fit(Xtr, ytr)
    p = model.predict(Xte)
    metrics = {"MAE": float(mean_absolute_error(yte, p)),
               "MAPE": float(mean_absolute_percentage_error(yte, p)),
               "R2": float(r2_score(yte, p))}
    save_model("baseline_rf", model, feature_names=feats, target_col=target, train_metrics=metrics)
    print("[OK] train done", metrics)

if __name__ == "__main__": main()
PY
chmod +x scripts/train_models.py

echo "== 5/7 scripts/bench_models.py ==";
cat > scripts/bench_models.py <<PY
#!/usr/bin/env python3
from pathlib import Path
import json, glob, re
import pandas as pd
import numpy as np
from sklearn.metrics import mean_absolute_error, mean_absolute_percentage_error, r2_score
from services.model_store import list_model_paths, load

def _slug(s: str) -> str:
    s = re.sub(r"[^0-9a-zA-Z_]+", "_", s).strip("_").lower();
    return re.sub("_+", "_", s)

def find_csv() -> Path:
    pats = ["data/processed/*.csv","data/features/*.csv","data/raw/*.csv"]
    for p in pats:
        files = glob.glob(p);
        if files: return Path(sorted(files)[0])
    raise FileNotFoundError("Nenhum dataset encontrado. Rode scripts/train_models.py para gerar um demo.")

def prep(df: pd.DataFrame, target_hint: str | None):
    df = df.copy(); df.columns = [_slug(c) for c in df.columns]
    target = target_hint
    if target is None or target not in df.columns:
        for c in ["target","preco_unitario","valor","price","y"]:
            if c in df.columns: target = c; break
    if target is None: raise RuntimeError("Coluna alvo não encontrada.")
    for c in df.columns:
        if c == target: continue
        if df[c].dtype == "O": df[c] = df[c].astype("category").cat.codes
        if df[c].isna().any(): df[c] = df[c].fillna(df[c].median() if pd.api.types.is_numeric_dtype(df[c]) else 0)
    X = df.drop(columns=[target]); y = df[target].astype(float)
    return X, y, target

def main():
    paths = list_model_paths()
    if not paths: print("[WARN] Nenhum modelo encontrado."); return
    data_path = find_csv(); df = pd.read_csv(data_path, low_memory=False)
    out = {}
    for p in paths:
        meta_p = Path(p).with_name("metadata.json")
        meta = {}
        if meta_p.exists(): meta = json.loads(meta_p.read_text(encoding="utf-8"))
        feats = meta.get("feature_names")
        target_hint = meta.get("target_col")
        X, y, target = prep(df, target_hint)
        if feats: X = X[[c for c in feats if c in X.columns]]
        model = load(p)
        split = int(len(X)*0.2) or 1
        Xte, yte = X.iloc[-split:], y.iloc[-split:]
        pred = model.predict(Xte)
        m = {"MAE": float(mean_absolute_error(yte, pred)),
             "MAPE": float(mean_absolute_percentage_error(yte, pred)),
             "R2": float(r2_score(yte, pred))}
        out[str(p)] = {"metrics": m, "meta": meta}
        print(f"[BENCH] {p} -> {m}")
    Path("data/metrics").mkdir(parents=True, exist_ok=True)
    Path("data/metrics/model_bench.json").write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print("[OK] wrote data/metrics/model_bench.json")

if __name__ == "__main__": main()
PY
chmod +x scripts/bench_models.py

echo "== 6/7 scripts/report_monthly.py (já criado antes) ==";
if [ ! -f scripts/report_monthly.py ]; then
  cat > scripts/report_monthly.py <<PY
#!/usr/bin/env python3
from pathlib import Path
import json, pandas as pd
OUT = Path("data/reports"); OUT.mkdir(parents=True, exist_ok=True)
def load_kpis() -> dict:
    k = {}
    pncp = Path("data/processed/pncp_itens.csv")
    if pncp.exists():
        df = pd.read_csv(pncp); k["Registros PNCP"] = int(len(df))
        if "preco_unitario" in df.columns:
            import pandas as pd as _pd
            k["Preço médio PNCP"] = float(_pd.to_numeric(df["preco_unitario"], errors="coerce").mean())
    bench = Path("data/metrics/model_bench.json")
    if bench.exists(): k.update(json.loads(bench.read_text(encoding="utf-8")))
    return k
def main():
    k = load_kpis(); p = OUT / "relatorio_mensal.md"
    lines = ["# Relatório Mensal",""] + [f"- {kk}: {vv}" for kk,vv in k.items()]
    p.write_text("\\n".join(lines), encoding="utf-8"); print(f"[REPORT] {p}")
if __name__ == "__main__": main()
PY
  chmod +x scripts/report_monthly.py
fi

echo "== 7/7 rodando: train -> bench -> report ==";
python scripts/train_models.py || true
python scripts/bench_models.py || true
python scripts/report_monthly.py || true
echo "== FIM ==" \
