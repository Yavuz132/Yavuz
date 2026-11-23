import json
import shutil
from pathlib import Path
import click
from . import workflows as W
from .config import BRAND_FILE, ROOT, load_brand


@click.group()
@click.option("--brand", "brand_file", type=click.Path(), default=None, help="Marka YAML yolu")
@click.pass_context
def cli(ctx, brand_file):
    """Sosyal Medya Stüdyosu — strateji, çekim, edit, rakip analizi, caption, reels."""
    ctx.obj = {"brand_file": brand_file}


def _brand(ctx):
    return load_brand(ctx.obj["brand_file"])


@cli.command()
def init():
    """Marka dosyasını ve çalışma klasörlerini oluşturur."""
    if not BRAND_FILE.exists():
        shutil.copy(ROOT / "brand" / "brand.example.yaml", BRAND_FILE)
        click.echo(f"Oluşturuldu: {BRAND_FILE} — düzenleyin.")
    for d in ("workspace/fotograflar", "workspace/rakipler/ornek-rakip"):
        (ROOT / d).mkdir(parents=True, exist_ok=True)
    click.echo("Klasörler hazır: workspace/fotograflar, workspace/rakipler/<rakip-adi>/")


@cli.command()
@click.option("--days", default=30)
@click.option("--start", default=None, help="YYYY-MM-DD")
@click.option("--focus", default="-", help="Kampanya/odak notu")
@click.pass_context
def plan(ctx, days, start, focus):
    """İçerik stratejisi + takvim (md/csv/json)."""
    click.echo(f"Takvim: {W.plan_calendar(_brand(ctx), days, start, focus)}")


@cli.command()
@click.argument("topic")
@click.option("--platform", default="instagram")
@click.option("--format", "fmt", default="post")
@click.option("--notes", default="-")
@click.pass_context
def caption(ctx, topic, platform, fmt, notes):
    """Caption + hashtag varyantları."""
    d = W.write_caption(_brand(ctx), topic, platform, fmt, notes)
    for v in d["variants"]:
        click.echo(f"\n[{v['label']}] {v['hook']}\n{v['caption']}\n{v['cta']}\n{' '.join(v['hashtags'])}")
    click.echo(f"\nÖnerilen: {d['best_pick']} — {d['why']}")


@cli.command()
@click.argument("topic")
@click.option("--seconds", default=20)
@click.option("--platform", default="instagram")
@click.option("--notes", default="-")
@click.option("--render", is_flag=True, help="Sahneleri Runway ile videoya çevir (kredi harcar)")
@click.option("--start-image", type=click.Path(exists=True), default=None, help="Tüm sahneler için başlangıç karesi")
@click.option("--clip-seconds", type=click.Choice(["5", "10"]), default="5")
@click.pass_context
def reel(ctx, topic, seconds, platform, notes, render, start_image, clip_seconds):
    """Reels/TikTok senaryosu + storyboard (+ Runway ile klipler)."""
    d = W.make_reel(_brand(ctx), topic, seconds, platform, notes, render=render,
                    start_image=start_image, clip_seconds=int(clip_seconds))
    click.echo(f"\n{d['title']}\nHook: {d['hook_text']}\nSes: {d['audio']['suggestion']}")
    for s in d["scenes"]:
        click.echo(f" {s['n']}. [{s['seconds']}sn] {s['shot']} | yazı: {s['on_screen_text']} | ses: {s['voiceover']}")
    click.echo(f"\nCaption: {d['caption']}\n{' '.join(d['hashtags'])}")


@cli.command()
@click.argument("image", type=click.Path(exists=True))
@click.argument("prompt")
@click.option("--ratio", default="720:1280")
@click.option("--duration", type=click.Choice(["5", "10"]), default="5")
def animate(image, prompt, ratio, duration):
    """Tek fotoğrafı Runway ile videoya çevirir."""
    click.echo(f"Video: {W.animate(image, prompt, ratio, int(duration))}")


@cli.command()
@click.argument("topic")
@click.option("--location", default="-")
@click.option("--gear", default="telefon")
@click.option("--notes", default="-")
@click.option("--moodboard", is_flag=True, help="AI moodboard görseli üret")
@click.pass_context
def shoot(ctx, topic, location, gear, notes, moodboard):
    """Fotoğraf çekim planı / shot list."""
    d = W.shoot_plan(_brand(ctx), topic, location, gear, notes, moodboard)
    click.echo(f"Konsept: {d['concept']}\nIşık: {d['lighting']['setup']}")
    for s in d["shots"]:
        click.echo(f" {s['n']}. {s['name']} — {s['framing']}, {s['angle']}, {s['settings']} ({s['use']})")


@cli.command()
@click.argument("folder", type=click.Path(exists=True), default="workspace/fotograflar")
@click.option("--notes", default="-")
@click.option("--ai-edit", is_flag=True, help="gpt-image ile ek AI düzenleme")
@click.pass_context
def edit(ctx, folder, notes, ai_edit):
    """Fotoğrafları değerlendir, rötuşla, kırp (+ opsiyonel AI edit)."""
    d = W.review_and_edit(_brand(ctx), folder, notes, ai_edit)
    for p in d["photos"]:
        click.echo(f" {p['file']}: {p['score']}/10 → {p['best_use']} | {p.get('output', '')}")
    click.echo(f"Kapak önerisi: {d['cover_pick']}")


@cli.command()
@click.argument("folder", type=click.Path(exists=True), default="workspace/fotograflar")
@click.option("--ratio", type=click.Choice(["4:5", "9:16", "1:1", "16:9"]), default="4:5")
def resize(folder, ratio):
    """Toplu platform boyutlandırma (API gerektirmez)."""
    for o in W.resize_all(folder, ratio):
        click.echo(o)


@cli.command()
@click.argument("folder", type=click.Path(exists=True), default="workspace/rakipler")
@click.pass_context
def competitors(ctx, folder):
    """Rakip analizi: workspace/rakipler/<rakip>/ içindeki metin ve ekran görüntülerinden."""
    W.analyze_competitors(_brand(ctx), folder)
    click.echo("Rapor: output/rakip-analizi.md")


if __name__ == "__main__":
    cli()
