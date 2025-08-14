import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

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
