PERSONA = """Sen kıdemli bir sosyal medya uzmanısın: içerik stratejisti, sanat yönetmeni, foto/video çekim yönetmeni,
fotoğraf rötuşçusu, reels/TikTok kurgucusu ve rakip analisti rolünü birlikte üstleniyorsun.
Kurallar:
- Yanıt dili marka dosyasındaki dil (varsayılan Türkçe). Doğal, platform diline uygun yaz; çeviri kokan cümle kurma.
- Genel geçer tavsiye verme; markaya, sektöre, şehre ve hedef kitleye özel, uygulanabilir çıktı ver.
- Reels/TikTok'ta ilk 1-3 saniyede güçlü hook, sonunda net CTA ve kaydet/paylaş tetikleyicisi olsun.
- Uydurma istatistik, sahte yorum/ödül yazma. Bilmediğin veriyi 'varsayım' diye etiketle.
- Marka 'do_not' listesine kesinlikle uy.
"""

CALENDAR = """Aşağıdaki marka için {days} günlük içerik takvimi hazırla. Başlangıç tarihi: {start}.
Haftalık sıklık: marka dosyasındaki posting_frequency. İçerik sütunları (3-5 adet) belirle ve dengele
(eğitici, sosyal kanıt, perde arkası, ürün/hizmet, eğlence/trend, satış).
Ek odak/talimat: {focus}

SADECE JSON döndür:
{{"pillars":[{{"name":"","purpose":""}}],
"items":[{{"date":"YYYY-MM-DD","day":"Pzt","format":"reel|post|carousel|story","pillar":"","topic":"","hook":"",
"visual_idea":"","cta":"","best_time":"HH:MM"}}]}}"""

CAPTION = """Konu: {topic}
Platform: {platform} | Format: {fmt}
Ek not: {notes}

3 farklı varyant üret (A: bilgilendirici, B: hikâye/duygusal, C: kısa-vurucu). SADECE JSON:
{{"variants":[{{"label":"A","hook":"","caption":"","cta":"","hashtags":["#..."],"alt_text":"",
"first_comment":""}}],"best_pick":"A|B|C","why":""}}
Hashtag: 8-12 adet; geniş/orta/niş karışımı, marka ve şehir etiketi dahil."""

REEL = """Konu: {topic}
Süre hedefi: {seconds} sn | Platform: {platform} | Dikey 9:16
Ek not: {notes}

Çekilebilir ve kurgulanabilir bir reels planı yaz. SADECE JSON:
{{"title":"","hook_text":"","concept":"","audio":{{"type":"trend|voiceover|müzik","suggestion":""}},
"scenes":[{{"n":1,"seconds":3,"shot":"","camera":"","on_screen_text":"","voiceover":"",
"runway_prompt":"(İngilizce, 1 cümle: kamera hareketi + hareket eden özne + ışık; metin/logo isteme)"}}],
"caption":"","hashtags":[],"cta":"","edit_notes":"","cover_idea":""}}
Sahne sürelerinin toplamı hedef süreye yakın olsun; en fazla {max_scenes} sahne."""

SHOOT = """Konu/ürün: {topic}
Mekân/koşul: {location}
Ekipman: {gear}
Ek not: {notes}

Fotoğraf çekim planı hazırla. SADECE JSON:
{{"concept":"","moodboard_keywords":[],"palette":[],"props":[],"lighting":{{"setup":"","time_of_day":"","tips":[]}},
"shots":[{{"n":1,"name":"","framing":"","angle":"","lens_mm":"","settings":"ISO/diyafram/enstantane","direction":"",
"use":"feed|story|reel_cover|carousel"}}],
"phone_tips":[],"common_mistakes":[],"image_prompt":"(İngilizce moodboard görseli için tek paragraf prompt)"}}"""

PHOTO_REVIEW = """Bu fotoğrafları sosyal medya yayını için değerlendir ve rötuş talimatı ver.
Marka görsel stili dikkate alınsın. Ek not: {notes}
SADECE JSON:
{{"photos":[{{"file":"","score":0,"strengths":[],"issues":[],
"edit":{{"brightness":1.0,"contrast":1.0,"saturation":1.0,"sharpness":1.0,"warmth":0,"crop":"4:5|9:16|1:1|none"}},
"ai_edit_prompt":"(İngilizce; gpt-image edit için: neyi koru, neyi değiştir)",
"best_use":"feed|story|reel_cover|carousel|elenmeli"}}],"cover_pick":"","order_suggestion":[]}}
brightness/contrast/saturation/sharpness 1.0 = değişim yok (0.8-1.3 arası tut); warmth -20..20."""

COMPETITOR = """Aşağıda rakip hesaplara ait toplanmış veriler var (gönderi metinleri, metrikler, ekran görüntüleri).
Marka: yukarıdaki profil. Veride olmayanı UYDURMA; çıkarımları 'varsayım' diye işaretle.

{data}

Derin rakip analizi yap. SADECE JSON:
{{"competitors":[{{"name":"","positioning":"","content_mix":"","posting_rhythm":"","hooks_that_work":[],
"visual_style":"","engagement_notes":"","strengths":[],"weaknesses":[]}}],
"benchmark":{{"what_everyone_does":[],"gaps_we_can_own":[],"formats_to_test":[]}},
"swot":{{"S":[],"W":[],"O":[],"T":[]}},
"action_plan":[{{"priority":1,"action":"","why":"","kpi":""}}],
"content_ideas":[{{"format":"","hook":"","angle":"","inspired_by":""}}]}}"""
