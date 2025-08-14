# React + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.
```

### Ingestão PNCP (exemplo)
```bash
python coletas/pncp/thiagosy_runner.py \\
  --ufs AL BA SE \\
  --data-inicial 2024-06-25 \\
  --data-final   2024-06-26 \\
  --modalidade 6 \\
  --max-reg 500 \\
  --page-size 50 \\
  --keywords "alimentício,alimento" \\
  --excel-out "logs/pncp_20240625_20240626.xlsx"
```

### Ingestão priceAPI → SQLite
1) Baixe CSVs originais em `vendors/priceAPI/data/` com nomes no padrão `<fonte>-YYYY.MM.csv`
```bash
mkdir -p vendors/priceAPI/data
curl -L -o vendors/priceAPI/data/pmsp-2017.01.csv https://raw.githubusercontent.com/yorikvanhavre/priceAPI/master/data/pmsp-2017.01.csv
```
2) Ingestão:
```bash
python coletas/precos/priceapi_ingestor.py --data-folder vendors/priceAPI/data --db data/external/external.sqlite
```

### Rodando o dashboard
```bash
python -m streamlit run dashboards/licitanow/Meny.py
# Acesse: http://localhost:8502
```

## Testes e CI
Rodar local:
```bash
pytest -q
```

## Evitando arquivos grandes no Git
- `.gitignore` ignora: `data/`, `*.sqlite`, `*.csv`, `*.xlsx`, etc.
- Para amostras pequenas, use `samples/` (tamanho mínimo).
