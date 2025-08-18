from pathlib import Path
import yaml

def load_yaml(path: Path):
    if not path.exists():
        print(f"[WARN] {path} não existe.")
        return
    try:
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
        kind = type(data).__name__
        if data is None:
            print(f"[WARN] {path}: vazio")
        elif isinstance(data, dict):
            print(f"[OK] {path}: chaves -> {list(data.keys())}")
        else:
            print(f"[OK] {path}: tipo {kind}")
    except Exception as e:
        print(f"[ERRO] {path}: {e}")

def main():
    base = Path("config")
    for fname in ("licitacao.yaml", "legal_checklist.yml"):
        load_yaml(base / fname)

if __name__ == "__main__":
    main()
