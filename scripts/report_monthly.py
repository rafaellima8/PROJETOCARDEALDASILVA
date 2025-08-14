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
        path.write_text("\n".join(lines), encoding="utf-8")
        print(f"[REPORT] (fallback) Gerado {path} | Motivo PDF: {e}")

if __name__ == "__main__":
    main()
