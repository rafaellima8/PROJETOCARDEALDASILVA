.PHONY: install train bench report test precommit clean

install:
\tpython -m pip install -U pip
\t@if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
\tpip install pre-commit

train:
\tPYTHONPATH=. python scripts/train_models.py

bench:
\tPYTHONPATH=. python scripts/bench_models.py

report:
\tPYTHONPATH=. python scripts/report_monthly.py

test:
\tpytest -q

precommit:
\tpre-commit run --all-files

clean:
\trm -rf data/models data/metrics data/reports || true
