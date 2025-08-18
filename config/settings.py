from dataclasses import dataclass
import os

@dataclass(frozen=True)
class Settings:
    app_user: str = os.getenv("APP_USER", "admin")
    app_pass: str = os.getenv("APP_PASS", "admin")
    tz: str = os.getenv("TZ", "America/Bahia")
    uf_default: str = os.getenv("UF_DEFAULT", "BA")
    municipio: str = os.getenv("MUNICIPIO", "Cardeal da Silva - BA")
    ibge: str = os.getenv("IBGE", "2907004")

SETTINGS = Settings()
