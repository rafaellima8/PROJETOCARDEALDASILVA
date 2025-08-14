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
