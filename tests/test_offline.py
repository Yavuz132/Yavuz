"""API anahtarı gerektirmez: istemciler sahte yanıtlarla test edilir."""
import json
import os
from pathlib import Path
from unittest import mock

from PIL import Image

os.environ.update(OPENAI_API_KEY="x", RUNWAY_API_KEY="y")
from studio import workflows as W, config  # noqa: E402

BRAND = {"name": "Test", "language": "tr"}


def fake_chat(self, system, user, images=None, json_mode=False, temperature=0.8):
    if "takvimi" in user:
        return {"pillars": [{"name": "A", "purpose": "b"}], "items": [
            {"date": "2026-12-01", "day": "Sal", "format": "reel", "pillar": "A", "topic": "t", "hook": "h",
             "visual_idea": "v", "cta": "c", "best_time": "19:00"}]}
    if "Reels" in user or "reels" in user:
        return {"title": "T", "hook_text": "H", "audio": {"suggestion": "s"}, "caption": "c", "hashtags": [],
                "scenes": [{"n": 1, "seconds": 5, "shot": "s", "on_screen_text": "", "voiceover": "",
                            "runway_prompt": "slow dolly in"}]}
    if "fotoğrafları" in user:
        return {"photos": [{"file": "a.jpg", "score": 7, "edit": {"brightness": 1.1, "warmth": 5, "crop": "4:5"},
                            "best_use": "feed"}], "cover_pick": "a.jpg"}
    raise AssertionError(user[:60])


def test_calendar(tmp_path):
    with mock.patch.object(config, "OUT_DIR", tmp_path), \
         mock.patch("studio.openai_client.OpenAIClient.chat", fake_chat):
        p = W.plan_calendar(BRAND, 7)
    assert "İçerik Takvimi" in Path(p).read_text(encoding="utf-8")
    assert (tmp_path / "takvim.csv").exists()


def test_photo_edit_and_resize(tmp_path):
    src = tmp_path / "in"; src.mkdir()
    Image.new("RGB", (2000, 1500), (120, 90, 60)).save(src / "a.jpg")
    with mock.patch.object(config, "OUT_DIR", tmp_path / "out"), \
         mock.patch("studio.openai_client.OpenAIClient.chat", fake_chat):
        d = W.review_and_edit(BRAND, src)
        out = Image.open(d["photos"][0]["output"])
        assert out.size == (1080, 1350)
        assert W.resize_all(src, "9:16")


def test_reel_render_runway(tmp_path):
    from studio.runway_client import RunwayClient
    posted = []

    def post(url, **kw):
        posted.append((url, kw["json"]))
        r = mock.Mock(ok=True); r.json.return_value = {"id": "t1"}; return r

    def get(url, **kw):
        r = mock.Mock(ok=True, content=b"vid")
        r.json.return_value = {"status": "SUCCEEDED", "output": ["http://x/v.mp4"]}
        return r

    img = tmp_path / "s.png"; Image.new("RGB", (64, 64)).save(img)
    with mock.patch.object(config, "OUT_DIR", tmp_path / "out"), \
         mock.patch("studio.openai_client.OpenAIClient.chat", fake_chat), \
         mock.patch("requests.post", post), mock.patch("requests.get", get):
        d = W.make_reel(BRAND, "konu", render=True, start_image=str(img))
    assert posted[0][0].endswith("/image_to_video")
    assert posted[0][1]["promptImage"].startswith("data:image/png;base64,")
    assert Path(d["clips"][0]).read_bytes() == b"vid"
