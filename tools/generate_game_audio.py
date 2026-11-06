"""Generate Szept Peruna assets with ACE-Step 1.5 and the AudioLDM model.

Run with .local-audio/venv/Scripts/python.exe. Models stay outside game exports.
AudioLDM outputs are previews due to the model's CC BY-NC-SA 4.0 license.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import ssl
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
LOCAL = ROOT / ".local-audio"
OUTPUT = ROOT / "tmp" / "audio-complete"
ACE = LOCAL / "ACE-Step-1.5"
SFX_MODEL = "cvssp/audioldm-s-full-v2"
MUSIC_MODEL = "ACE-Step/Ace-Step1.5"

from audio_catalog import MUSIC, SFX


def configure():
    LOCAL.mkdir(exist_ok=True)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / ".gdignore").touch()
    os.environ.setdefault("HF_HOME", str(LOCAL / "hf-cache"))
    os.environ.setdefault("HF_HUB_DISABLE_XET", "1")
    os.environ.setdefault("HF_HUB_DISABLE_SYMLINKS_WARNING", "1")
    os.environ.setdefault("TOKENIZERS_PARALLELISM", "false")
    # Use Windows' trusted CA store without disabling HTTPS verification.
    if sys.platform == "win32":
        certificates = ssl.create_default_context().get_ca_certs(binary_form=True)
        bundle = LOCAL / "trusted-ca.pem"
        bundle.write_text("".join(ssl.DER_cert_to_PEM_cert(c) for c in certificates), encoding="ascii")
        os.environ["REQUESTS_CA_BUNDLE"] = str(bundle)
        os.environ["SSL_CERT_FILE"] = str(bundle)


def download(which):
    from huggingface_hub import snapshot_download, HfApi
    repo = MUSIC_MODEL if which == "music" else SFX_MODEL
    destination = ACE / "checkpoints" if which == "music" else LOCAL / "models" / "audioldm-s-full-v2"
    if (destination / "provenance.json").exists():
        return destination # Reuse the already pinned, downloaded model revision.
    patterns = ["acestep-v15-turbo/*", "vae/*", "Qwen3-Embedding-0.6B/*", "README.md", "LICENSE"] if which == "music" else ["*.json", "*.txt", "*.safetensors", "*.model", "README.md"]
    info = HfApi().model_info(repo)
    print(f"Downloading {repo} revision {info.sha} to {destination}", flush=True)
    snapshot_download(repo, revision=info.sha, local_dir=destination, allow_patterns=patterns, max_workers=2)
    provenance = {"repository": repo, "revision": info.sha, "license": "MIT" if which == "music" else "CC-BY-NC-SA-4.0"}
    (destination / "provenance.json").write_text(json.dumps(provenance, indent=2), encoding="utf-8")
    return destination


def record(name, prompt, seed, source, path, seconds, extra=None):
    import soundfile as sf
    import numpy as np
    samples, rate = sf.read(path, always_2d=True)
    if not np.isfinite(samples).all() or np.max(np.abs(samples)) < .001:
        raise RuntimeError(f"Invalid or silent audio: {path}")
    entry = {"name": name, "prompt": prompt, "seed": seed, "generator": source,
             "file": str(path.relative_to(ROOT)), "duration": len(samples) / rate,
             "sample_rate": rate, "channels": samples.shape[1], "peak": float(np.max(np.abs(samples))),
             "rms": float(np.sqrt(np.mean(samples ** 2))), "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
             "generation_seconds": round(seconds, 2), **(extra or {})}
    from filelock import FileLock
    with FileLock(str(OUTPUT / "manifest.lock")):
        manifest = OUTPUT / "manifest.json"
        entries = json.loads(manifest.read_text(encoding="utf-8")) if manifest.exists() else []
        entries = [e for e in entries if e["name"] != name] + [entry]
        manifest.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(entry, ensure_ascii=False), flush=True)


def finish_sfx(audio, rate, duration):
    import numpy as np
    audio = np.asarray(audio, dtype=np.float32)
    if audio.ndim != 1 or not np.isfinite(audio).all():
        raise RuntimeError("Invalid AudioLDM output")
    count = min(len(audio), int(duration * rate))
    # Select the strongest event window, rather than cutting a potentially silent intro.
    energy = np.concatenate(([0.], np.cumsum(audio.astype(np.float64) ** 2)))
    start = max(0, int(np.argmax(energy[count:] - energy[:-count])) - int(rate * .015))
    clip = audio[start:start + count].copy()
    fade = min(int(rate * .002), count // 4)
    clip[:fade] *= np.linspace(0, 1, fade)
    tail = min(int(rate * .06), count // 3)
    clip[-tail:] *= np.linspace(1, 0, tail)
    peak = float(np.max(np.abs(clip)))
    if peak < 1e-6:
        raise RuntimeError("Silent generated effect")
    return clip * (10 ** (-6 / 20) / peak)


def sfx(args):
    from filelock import FileLock
    with FileLock(str(LOCAL / "gpu-generation.lock")):
        return generate_sfx(args)


def generate_sfx(args):
    import torch
    import soundfile as sf
    from diffusers import AudioLDMPipeline
    model_path = download("sfx")
    torch.set_num_threads(args.threads)
    pipe = AudioLDMPipeline.from_pretrained(model_path, torch_dtype=torch.float32, use_safetensors=True)
    pipe = pipe.to(args.device)
    pipe.enable_attention_slicing()
    raw_dir = OUTPUT / "audioldm" / "raw"
    raw_dir.mkdir(parents=True, exist_ok=True)
    selected = SFX[:args.limit] if args.limit else SFX
    for index, spec in enumerate(selected):
        name, duration, prompt = spec["name"], spec["duration"], spec["prompt"]
        target = raw_dir.parent / f"{name}.wav"
        if target.exists() and not args.force:
            print(f"Already generated: {target}", flush=True)
            continue
        seed = 63000 + index
        started = time.monotonic()
        audio = pipe(prompt, negative_prompt="speech, talking, singing, music, hiss, background noise, distorted clipping", audio_length_in_s=5.0, num_inference_steps=args.steps, guidance_scale=2.5, generator=torch.Generator(device=args.device).manual_seed(seed)).audios[0]
        sf.write(raw_dir / f"{name}.wav", audio, 16000, subtype="PCM_16")
        clip = finish_sfx(audio, 16000, duration)
        from scipy.signal import resample_poly
        clip = resample_poly(clip, 441, 160)
        clip *= (10 ** (-6 / 20)) / max(1e-9, abs(clip).max())
        sf.write(target, clip, 44100, subtype="PCM_16")
        record(name, prompt, seed, "AudioLDM s-full-v2", target, time.monotonic() - started,
               {"license": "CC-BY-NC-SA-4.0", "release_status": "preview_only", "steps": args.steps,
                "group": spec["group"], "label": spec["label"], "duration_range": spec["range"], "native_model_rate": 16000})


def music(args):
    import torch
    import numpy as np
    import soundfile as sf
    sys.path.insert(0, str(ACE))
    from acestep.handler import AceStepHandler
    from acestep.llm_inference import LLMHandler
    from acestep.inference import GenerationParams, GenerationConfig, generate_music
    download("music")
    torch.set_num_threads(args.threads)
    class DitOnlyHandler(AceStepHandler):
        def _ensure_models_present(self, *, checkpoint_path, config_path, **kwargs):
            # The upstream check also requests an unused 1.7B language model.
            # Our explicit instrumental prompts use DiT-only generation.
            from acestep.model_downloader import _contains_model_weights
            missing = [part for part in (config_path, "vae", "Qwen3-Embedding-0.6B")
                       if not _contains_model_weights(checkpoint_path / part)]
            return (f"Missing model components: {missing}", False) if missing else None

        def tiled_decode(self, latents, **kwargs):
            if not args.vae_cuda or not torch.cuda.is_available():
                return super().tiled_decode(latents, **kwargs)
            from filelock import FileLock
            with FileLock(str(LOCAL / "gpu-generation.lock")):
                try:
                    self.vae.to(device="cuda", dtype=torch.float32)
                    return super().tiled_decode(latents.to(device="cuda", dtype=torch.float32),
                            chunk_size=192, overlap=48, offload_wav_to_cpu=True).cpu()
                except torch.cuda.OutOfMemoryError:
                    self.vae.cpu().float()
                    torch.cuda.empty_cache()
                    return super().tiled_decode(latents.cpu().float(), **kwargs)
                finally:
                    self.vae.cpu().float()
                    torch.cuda.empty_cache()

    handler = DitOnlyHandler()
    status, success = handler.initialize_service(project_root=str(ACE), config_path="acestep-v15-turbo", device=args.device,
            use_flash_attention=False, compile_model=False, offload_to_cpu=args.device == "cuda", offload_dit_to_cpu=args.device == "cuda", quantization=None)
    print(status, flush=True)
    if not success:
        raise RuntimeError(status)
    out_dir = OUTPUT / "ace-step"
    out_dir.mkdir(exist_ok=True)
    selected = MUSIC[:args.limit] if args.limit else MUSIC
    for index, spec in enumerate(selected):
        name, bpm, key, prompt = spec["name"], spec["bpm"], spec["key"], spec["prompt"]
        target = out_dir / f"{name}.wav"
        if target.exists() and not args.force:
            continue
        seed = 64000 + index
        started = time.monotonic()
        params = GenerationParams(caption=prompt, lyrics="[Instrumental]", instrumental=True, bpm=bpm,
                keyscale=key, timesignature="4", duration=spec["duration"] + 1 if spec["loop"] else 10, inference_steps=8,
                seed=seed, thinking=False, use_cot_metas=False, use_cot_caption=False, use_cot_language=False)
        config = GenerationConfig(batch_size=1, use_random_seed=False, seeds=[seed], audio_format="wav")
        result = generate_music(handler, LLMHandler(), params, config, save_dir=str(out_dir / "raw"))
        if not result.success or not result.audios:
            raise RuntimeError(result.error or "No audio returned")
        generated = result.audios[0]
        audio, rate = sf.read(generated["path"], always_2d=True)
        if spec["loop"]:
            fade = rate
            count = int(round(spec["duration"] * rate))
            audio = audio[:count + fade]
            loop = audio[fade:].copy()
            ramp = np.linspace(0, 1, fade)[:, None]
            loop[-fade:] = audio[-fade:] * (1-ramp) + audio[:fade] * ramp
        else:
            # Keep a compact, complete musical phrase from the native 10 s generation.
            count = int(spec["duration"] * rate)
            energy = np.mean(audio**2, axis=1)
            sums = np.concatenate(([0.], np.cumsum(energy)))
            start = max(0, int(np.argmax(sums[count:] - sums[:-count])) - int(.04 * rate))
            loop = audio[start:start + count].copy()
            loop[:int(.015*rate)] *= np.linspace(0, 1, int(.015*rate))[:, None]
            loop[-int(.3*rate):] *= np.linspace(1, 0, int(.3*rate))[:, None]
            fade = 0
        intermediate = out_dir / "raw" / f"{name}_edited.wav"
        sf.write(intermediate, loop, rate, subtype="PCM_16")
        subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(intermediate),
                        "-ar", "44100", "-c:a", "pcm_s16le", str(target)], check=True)
        ogg = target.with_suffix(".ogg")
        subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(target),
                        "-af", "loudnorm=I=-20:TP=-2:LRA=9", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5", str(ogg)], check=True)
        record(name, prompt, seed, "ACE-Step 1.5 turbo", target, time.monotonic()-started,
               {"license": "MIT (model)", "ogg": str(ogg.relative_to(ROOT)), "loop_crossfade_seconds": fade / rate,
                "group": spec["group"], "label": spec["label"], "duration_range": spec["range"], "loop": spec["loop"]})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("task", choices=["download-music", "download-sfx", "music", "sfx"])
    parser.add_argument("--device", choices=["cpu", "cuda"], default="cpu")
    parser.add_argument("--threads", type=int, default=6)
    parser.add_argument("--steps", type=int, default=24)
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--vae-cuda", action="store_true", help="Use GPU only for tiled VAE decoding; keep DiT on CPU.")
    args = parser.parse_args()
    configure()
    if args.task.startswith("download-"):
        download(args.task.removeprefix("download-"))
    else:
        {"sfx": sfx, "music": music}[args.task](args)


if __name__ == "__main__":
    main()
