import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

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
