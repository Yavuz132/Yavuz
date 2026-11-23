"""Runway API istemcisi: image→video, text→image, görev takibi."""
import base64
import mimetypes
import time
from pathlib import Path
import requests
from .config import env

API = "https://api.dev.runwayml.com/v1"
VERSION = "2024-11-06"


class RunwayClient:
    def __init__(self):
        self.key = env("RUNWAY_API_KEY", required=True)
        self.video_model = env("RUNWAY_VIDEO_MODEL", "gen4_turbo")
        self.image_model = env("RUNWAY_IMAGE_MODEL", "gen4_image")

    @property
    def _h(self):
        return {"Authorization": f"Bearer {self.key}", "X-Runway-Version": VERSION,
                "Content-Type": "application/json"}

    @staticmethod
    def to_data_uri(path_or_url: str) -> str:
        if path_or_url.startswith(("http://", "https://", "data:")):
            return path_or_url
        p = Path(path_or_url)
        mime = mimetypes.guess_type(p.name)[0] or "image/png"
        return f"data:{mime};base64,{base64.b64encode(p.read_bytes()).decode()}"

    def _post(self, route: str, body: dict) -> str:
        r = requests.post(f"{API}/{route}", headers=self._h, json=body, timeout=120)
        if not r.ok:
            raise RuntimeError(f"Runway hata {r.status_code}: {r.text[:500]}")
        return r.json()["id"]

    def image_to_video(self, image: str, prompt: str, ratio: str = "720:1280",
                       duration: int = 5, seed: int | None = None) -> str:
        body = {"model": self.video_model, "promptImage": self.to_data_uri(image),
                "promptText": prompt[:1000], "ratio": ratio, "duration": duration}
        if seed is not None:
            body["seed"] = seed
        return self._post("image_to_video", body)

    def text_to_image(self, prompt: str, ratio: str = "1080:1920", references: list | None = None) -> str:
        body = {"model": self.image_model, "promptText": prompt[:1000], "ratio": ratio}
        if references:
            body["referenceImages"] = [{"uri": self.to_data_uri(r), "tag": f"ref{i+1}"}
                                       for i, r in enumerate(references)]
        return self._post("text_to_image", body)

    def wait(self, task_id: str, poll: float = 5, timeout: float = 900) -> list[str]:
        t0 = time.time()
        while time.time() - t0 < timeout:
            r = requests.get(f"{API}/tasks/{task_id}", headers=self._h, timeout=60)
            if not r.ok:
                raise RuntimeError(f"Runway hata {r.status_code}: {r.text[:300]}")
            d = r.json()
            if d["status"] == "SUCCEEDED":
                return d["output"]
            if d["status"] in ("FAILED", "CANCELLED"):
                raise RuntimeError(f"Runway görevi başarısız: {d.get('failure') or d}")
            time.sleep(poll)
        raise TimeoutError(f"Runway görevi zaman aşımı: {task_id}")

    @staticmethod
    def download(url: str, out: Path) -> Path:
        r = requests.get(url, timeout=300)
        r.raise_for_status()
        out.write_bytes(r.content)
        return out
