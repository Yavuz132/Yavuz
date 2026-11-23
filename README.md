# Sosyal Medya Stüdyosu

OpenAI (metin + vision + görsel) ve Runway (video + görsel) API'leriyle çalışan, tek komutla kullanılan sosyal medya çalışma hattı.

| Rol | Komut | Çıktı |
|---|---|---|
| İçerik stratejisti | `plan` | `output/takvim.md/.csv/.json` |
| Metin yazarı | `caption` | 3 varyant caption + hashtag + alt text |
| Reels/TikTok yönetmeni | `reel [--render]` | Senaryo, storyboard, Runway klipleri (`output/reels/`) |
| Foto çekim yönetmeni | `shoot [--moodboard]` | Shot list, ışık, poz, moodboard |
| Foto editörü | `edit [--ai-edit]`, `resize` | Skorlama, rötuş, kırpma, AI düzenleme |
| Rakip analisti | `competitors` | `output/rakip-analizi.md` (SWOT, boşluklar, aksiyon planı) |
| Animasyon | `animate` | Tek fotoğraftan video |

## Kurulum
```bash
pip install -r requirements.txt
cp .env.example .env        # OPENAI_API_KEY ve RUNWAY_API_KEY girin
python -m studio init       # brand/brand.yaml + workspace klasörleri
# brand/brand.yaml dosyasını markanıza göre doldurun (en önemli adım)
```

## Kullanım
```bash
python -m studio plan --days 30 --focus "Ocak kampanyası"
python -m studio caption "Yeni sezon ürünü tanıtımı" --format carousel
python -m studio shoot "Kış koleksiyonu" --location "stüdyo, pencere ışığı" --moodboard
python -m studio edit workspace/fotograflar --ai-edit
python -m studio resize workspace/fotograflar --ratio 9:16
python -m studio reel "Perde arkası: ürün nasıl hazırlanıyor" --seconds 20            # sadece senaryo
python -m studio reel "Perde arkası" --render --start-image workspace/fotograflar/a.jpg  # Runway klipleri
python -m studio animate workspace/fotograflar/a.jpg "slow push-in, steam rising, warm light"
```

### Rakip analizi
Instagram/TikTok doğrudan kazınmaz (kullanım şartları + engellemeler). Bunun yerine:
```
workspace/rakipler/rakip1/gonderiler.txt   # caption'lar, beğeni/yorum sayıları (kopyala-yapıştır)
workspace/rakipler/rakip1/ekran1.png       # profil/grid/reels ekran görüntüleri
workspace/rakipler/rakip2/...
```
```bash
python -m studio competitors
```
Metrik/veri vermediğiniz yerde model varsayım olarak etiketler, uydurmaz.

## Notlar
- `--render` Runway kredisi harcar: sahne başına 1 video (+ başlangıç karesi yoksa 1 görsel). Önce senaryoyu `--render`'sız inceleyin.
- Modeller `.env` ile değişir (`OPENAI_MODEL`, `OPENAI_IMAGE_MODEL`, `RUNWAY_VIDEO_MODEL`). Runway sürüm başlığı `studio/runway_client.py` içinde.
- Yayınlama bu araçta yok; çıktıları Metricool/Meta Business Suite ile planlayabilirsiniz.
- Testler (anahtarsız): `python -m pytest tests`
