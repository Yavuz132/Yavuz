import os
from pathlib import Path
import yaml

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:  # dotenv opsiyonel
    pass

ROOT = Path(__file__).resolve().parent.parent
BRAND_FILE = ROOT / "brand" / "brand.yaml"
OUT_DIR = ROOT / "output"


def env(name: str, default: str | None = None, required: bool = False) -> str | None:
    v = os.getenv(name, default)
    if required and not v:
        raise SystemExit(f"Eksik ayar: {name}. .env dosyasına ekleyin (bkz. .env.example).")
    return v


def load_brand(path: Path | None = None) -> dict:
    p = Path(path) if path else BRAND_FILE
    if not p.exists():
        raise SystemExit(f"Marka dosyası yok: {p}\nÇalıştırın: python -m studio init")
    return yaml.safe_load(p.read_text(encoding="utf-8")) or {}


def brand_brief(brand: dict) -> str:
    return yaml.safe_dump(brand, allow_unicode=True, sort_keys=False)


def out_path(*parts: str) -> Path:
    p = OUT_DIR.joinpath(*parts)
    p.parent.mkdir(parents=True, exist_ok=True)
    return p
