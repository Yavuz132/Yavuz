"""İş akışları: strateji, caption, reels, çekim planı, foto edit, rakip analizi."""
import csv
import json
import time
from datetime import date
from pathlib import Path

from PIL import Image, ImageEnhance, ImageOps

from . import prompts as P
from .config import brand_brief, out_path
from .openai_client import OpenAIClient
from .runway_client import RunwayClient

IMG_EXT = {".jpg", ".jpeg", ".png", ".webp"}
RATIOS = {"4:5": (1080, 1350), "9:16": (1080, 1920), "1:1": (1080, 1080), "16:9": (1920, 1080)}


def _sys(brand: dict) -> str:
    return f"{P.PERSONA}\n\nMARKA PROFİLİ:\n{brand_brief(brand)}"


def _save_json(name: str, data: dict) -> Path:
    p = out_path(f"{name}.json")
    p.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    return p


def _slug(s: str) -> str:
    return "".join(c if c.isalnum() else "-" for c in s.lower())[:40].strip("-") or "icerik"


# ---------- 1) Strateji / takvim ----------
def plan_calendar(brand, days=30, start=None, focus="-"):
    ai = OpenAIClient()
    data = ai.chat(_sys(brand), P.CALENDAR.format(days=days, start=start or date.today().isoformat(), focus=focus),
                   json_mode=True)
    _save_json("takvim", data)
    md = ["# İçerik Takvimi\n", "## Sütunlar"] + [f"- **{p['name']}** — {p['purpose']}" for p in data["pillars"]]
    md += ["\n| Tarih | Gün | Format | Sütun | Konu | Hook | Saat |", "|---|---|---|---|---|---|---|"]
    for i in data["items"]:
        md.append(f"| {i['date']} | {i['day']} | {i['format']} | {i['pillar']} | {i['topic']} | {i['hook']} | {i['best_time']} |")
    p = out_path("takvim.md")
    p.write_text("\n".join(md), encoding="utf-8")
    with open(out_path("takvim.csv"), "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=list(data["items"][0].keys()))
        w.writeheader()
        w.writerows(data["items"])
    return p


# ---------- 2) Caption ----------
def write_caption(brand, topic, platform="instagram", fmt="post", notes="-"):
    data = OpenAIClient().chat(_sys(brand), P.CAPTION.format(topic=topic, platform=platform, fmt=fmt, notes=notes),
                               json_mode=True)
    _save_json(f"caption-{_slug(topic)}", data)
    return data


# ---------- 3) Reels ----------
def make_reel(brand, topic, seconds=20, platform="instagram", notes="-", max_scenes=6,
              render=False, start_image=None, clip_seconds=5, ratio="720:1280"):
    ai = OpenAIClient()
    data = ai.chat(_sys(brand), P.REEL.format(topic=topic, seconds=seconds, platform=platform, notes=notes,
                                              max_scenes=max_scenes), json_mode=True)
    slug = _slug(topic)
    _save_json(f"reel-{slug}", data)
    if render:
        data["clips"] = render_scenes(data["scenes"], slug, start_image, clip_seconds, ratio, brand)
        _save_json(f"reel-{slug}", data)
    return data


def render_scenes(scenes, slug, start_image=None, clip_seconds=5, ratio="720:1280", brand=None):
    """Her sahne için Runway'de görsel (gerekirse) + video üretir."""
    rw = RunwayClient()
    style = (brand or {}).get("visual_style", "")
    clips = []
    for s in scenes:
        img = start_image
        prompt = s["runway_prompt"]
        if not img:  # başlangıç karesi yoksa önce Runway ile üret
            tid = rw.text_to_image(f"{prompt}. Style: {style}", ratio="1080:1920")
            url = rw.wait(tid)[0]
            img = str(rw.download(url, out_path("reels", slug, f"sahne{s['n']}.png")))
        tid = rw.image_to_video(img, prompt, ratio=ratio, duration=clip_seconds)
        url = rw.wait(tid)[0]
        clip = rw.download(url, out_path("reels", slug, f"sahne{s['n']}.mp4"))
        clips.append(str(clip))
        print(f"  ✓ sahne {s['n']} -> {clip}")
    return clips


def animate(image, prompt, ratio="720:1280", duration=5):
    rw = RunwayClient()
    url = rw.wait(rw.image_to_video(image, prompt, ratio=ratio, duration=duration))[0]
    return rw.download(url, out_path("video", f"{Path(image).stem}-{int(time.time())}.mp4"))


# ---------- 4) Çekim planı ----------
def shoot_plan(brand, topic, location="-", gear="telefon", notes="-", moodboard=False):
    ai = OpenAIClient()
    data = ai.chat(_sys(brand), P.SHOOT.format(topic=topic, location=location, gear=gear, notes=notes), json_mode=True)
    slug = _slug(topic)
    _save_json(f"cekim-{slug}", data)
    if moodboard:
        data["moodboard_image"] = str(ai.generate_image(data["image_prompt"], out_path(f"cekim-{slug}-moodboard.png")))
        _save_json(f"cekim-{slug}", data)
    return data


# ---------- 5) Foto edit ----------
def _list_images(folder):
    p = Path(folder)
    return [p] if p.is_file() else sorted(f for f in p.iterdir() if f.suffix.lower() in IMG_EXT)


def apply_edit(img_path, edit: dict, out: Path) -> Path:
    im = ImageOps.exif_transpose(Image.open(img_path)).convert("RGB")
    for key, enh in (("brightness", ImageEnhance.Brightness), ("contrast", ImageEnhance.Contrast),
                     ("saturation", ImageEnhance.Color), ("sharpness", ImageEnhance.Sharpness)):
        v = max(0.6, min(1.5, float(edit.get(key, 1.0))))
        im = enh(im).enhance(v)
    w = max(-20, min(20, float(edit.get("warmth", 0))))
    if w:
        r, g, b = im.split()
        r = r.point(lambda x: min(255, x + w))
        b = b.point(lambda x: max(0, x - w))
        im = Image.merge("RGB", (r, g, b))
    crop = edit.get("crop", "none")
    if crop in RATIOS:
        im = ImageOps.fit(im, RATIOS[crop], Image.LANCZOS)
    im.save(out, quality=95)
    return out


def review_and_edit(brand, folder, notes="-", ai_edit=False):
    """Fotoğrafları vision ile değerlendirir, rötuşu uygular; isteğe bağlı gpt-image ile AI düzenleme."""
    ai = OpenAIClient()
    imgs = _list_images(folder)[:10]
    if not imgs:
        raise SystemExit("Klasörde görsel bulunamadı.")
    names = ", ".join(i.name for i in imgs)
    data = ai.chat(_sys(brand), P.PHOTO_REVIEW.format(notes=notes) + f"\nDosya sırası: {names}",
                   images=imgs, json_mode=True)
    byname = {i.name: i for i in imgs}
    for ph in data["photos"]:
        src = byname.get(ph["file"])
        if not src:
            continue
        out = out_path("foto", f"{src.stem}-edit.jpg")
        ph["output"] = str(apply_edit(src, ph["edit"], out))
        if ai_edit and ph.get("ai_edit_prompt") and ph.get("best_use") != "elenmeli":
            ph["ai_output"] = str(ai.edit_image([src], ph["ai_edit_prompt"], out_path("foto", f"{src.stem}-ai.png")))
    _save_json("foto-degerlendirme", data)
    return data


def resize_all(folder, ratio="4:5"):
    outs = []
    for f in _list_images(folder):
        im = ImageOps.fit(ImageOps.exif_transpose(Image.open(f)).convert("RGB"), RATIOS[ratio], Image.LANCZOS)
        o = out_path("boyut", f"{f.stem}-{ratio.replace(':', 'x')}.jpg")
        im.save(o, quality=95)
        outs.append(o)
    return outs


# ---------- 6) Rakip analizi ----------
def _collect(folder):
    """workspace/rakipler/<rakip>/ altındaki .txt/.md/.json/.csv metinleri + görselleri toplar."""
    root = Path(folder)
    text, images = [], []
    for d in sorted(p for p in root.iterdir() if p.is_dir()):
        text.append(f"\n=== RAKİP: {d.name} ===")
        for f in sorted(d.iterdir()):
            if f.suffix.lower() in IMG_EXT:
                images.append(f)
                text.append(f"[görsel: {d.name}/{f.name}]")
            elif f.suffix.lower() in {".txt", ".md", ".json", ".csv"}:
                text.append(f"--- {f.name} ---\n{f.read_text(encoding='utf-8', errors='ignore')[:6000]}")
    return "\n".join(text), images[:8]


def analyze_competitors(brand, folder):
    text, images = _collect(folder)
    if not text.strip():
        raise SystemExit(f"{folder} boş. Her rakip için alt klasör açıp gönderi metni/ekran görüntüsü koyun.")
    data = OpenAIClient().chat(_sys(brand), P.COMPETITOR.format(data=text), images=images, json_mode=True)
    _save_json("rakip-analizi", data)
    out_path("rakip-analizi.md").write_text(_competitor_md(data), encoding="utf-8")
    return data


def _competitor_md(d):
    L = ["# Rakip Analizi\n"]
    for c in d["competitors"]:
        L += [f"## {c['name']}", f"- Konum: {c['positioning']}", f"- İçerik karması: {c['content_mix']}",
              f"- Ritim: {c['posting_rhythm']}", f"- Görsel dil: {c['visual_style']}",
              "- Çalışan hook'lar: " + "; ".join(c["hooks_that_work"]),
              "- Güçlü: " + "; ".join(c["strengths"]), "- Zayıf: " + "; ".join(c["weaknesses"]), ""]
    b = d["benchmark"]
    L += ["## Benchmark", "- Herkes yapıyor: " + "; ".join(b["what_everyone_does"]),
          "- Sahiplenebileceğimiz boşluklar: " + "; ".join(b["gaps_we_can_own"]),
          "- Test edilecek formatlar: " + "; ".join(b["formats_to_test"]), "", "## SWOT"]
    for k, v in d["swot"].items():
        L.append(f"- **{k}**: " + "; ".join(v))
    L += ["", "## Aksiyon Planı"] + [f"{a['priority']}. **{a['action']}** — {a['why']} _(KPI: {a['kpi']})_" for a in d["action_plan"]]
    L += ["", "## İçerik Fikirleri"] + [f"- [{i['format']}] {i['hook']} — {i['angle']} (ilham: {i['inspired_by']})" for i in d["content_ideas"]]
    return "\n".join(L)
