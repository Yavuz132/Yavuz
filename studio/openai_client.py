"""OpenAI için ince istemci (SDK gerektirmez): sohbet/JSON, vision, görsel üret/düzenle."""
import base64
import json
import mimetypes
from pathlib import Path
import requests
from .config import env

API = "https://api.openai.com/v1"


class OpenAIClient:
    def __init__(self):
        self.key = env("OPENAI_API_KEY", required=True)
        self.model = env("OPENAI_MODEL", "gpt-4o")
        self.image_model = env("OPENAI_IMAGE_MODEL", "gpt-image-1")

    @property
    def _h(self):
        return {"Authorization": f"Bearer {self.key}"}

    @staticmethod
    def _check(r: requests.Response):
        if not r.ok:
            raise RuntimeError(f"OpenAI hata {r.status_code}: {r.text[:500]}")
        return r.json()

    @staticmethod
    def image_part(path: str | Path) -> dict:
        p = Path(path)
        mime = mimetypes.guess_type(p.name)[0] or "image/jpeg"
        b64 = base64.b64encode(p.read_bytes()).decode()
        return {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{b64}"}}

    def chat(self, system: str, user: str, images: list | None = None,
             json_mode: bool = False, temperature: float = 0.8) -> str | dict:
        content = [{"type": "text", "text": user}] + [self.image_part(i) for i in (images or [])]
        body = {
            "model": self.model,
            "temperature": temperature,
            "messages": [{"role": "system", "content": system},
                         {"role": "user", "content": content if images else user}],
        }
        if json_mode:
            body["response_format"] = {"type": "json_object"}
        r = requests.post(f"{API}/chat/completions", headers=self._h, json=body, timeout=180)
        text = self._check(r)["choices"][0]["message"]["content"]
        return json.loads(text) if json_mode else text

    def generate_image(self, prompt: str, out: Path, size: str = "1024x1536", quality: str = "high") -> Path:
        r = requests.post(f"{API}/images/generations", headers=self._h, timeout=300,
                          json={"model": self.image_model, "prompt": prompt, "size": size, "quality": quality})
        out.write_bytes(base64.b64decode(self._check(r)["data"][0]["b64_json"]))
        return out

    def edit_image(self, images: list, prompt: str, out: Path, size: str = "1024x1536",
                   quality: str = "high", mask: str | None = None) -> Path:
        files = [("image[]", (Path(i).name, open(i, "rb"), mimetypes.guess_type(str(i))[0] or "image/png"))
                 for i in images]
        if mask:
            files.append(("mask", (Path(mask).name, open(mask, "rb"), "image/png")))
        data = {"model": self.image_model, "prompt": prompt, "size": size, "quality": quality}
        r = requests.post(f"{API}/images/edits", headers=self._h, data=data, files=files, timeout=300)
        out.write_bytes(base64.b64decode(self._check(r)["data"][0]["b64_json"]))
        return out
