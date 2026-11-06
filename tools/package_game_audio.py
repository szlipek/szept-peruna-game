"""Validate generated audio and prepare an offline listening pack."""
import html
import json
import re
from pathlib import Path
import shutil
import subprocess
import zipfile

import numpy as np
import soundfile as sf
from audio_catalog import ALL, GROUPS

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tmp/audio-complete"
DESTINATION = ROOT / "art/audio/generated_complete"


def main():
    entries = json.loads((SOURCE / "manifest.json").read_text(encoding="utf-8"))
    assert {e["name"] for e in entries} == {s["name"] for s in ALL}, "Missing or unexpected generated assets"
    assert len(entries) == len(ALL), "Duplicate entries"
    document = (ROOT / "docs/audio-assets-lista.md").read_text(encoding="utf-8")
    requirements = {}
    for line in document.splitlines():
        found = re.match(r"\| P\d \| `([^`]+)`", line)
        if found:
            bounds = re.findall(r"\d+(?:,\d+)?", line.split("|")[-2])
            requirements[found[1]] = [float(n.replace(",", ".")) for n in bounds[:2]]
    assert set(requirements) == GROUPS, "Catalogue differs from the Markdown specification"
    DESTINATION.mkdir(parents=True, exist_ok=True)
    (DESTINATION / ".gdignore").touch()
    rows = []
    report = []
    for entry in sorted(entries, key=lambda e: (e["generator"].startswith("AudioLDM"), e["name"])):
        source = ROOT / entry["file"]
        data, rate = sf.read(source, always_2d=True)
        assert rate == 44100 and sf.info(source).subtype == "PCM_16", source
        low, high = requirements[entry["group"]]
        assert low - .001 <= len(data)/rate <= high + .001, f"Duration outside spec: {source}"
        assert np.isfinite(data).all(), source
        assert float(np.max(np.abs(data))) < .999, f"Clipping: {source}"
        assert float(np.sqrt(np.mean(data ** 2))) > .0001, f"Silence: {source}"
        folder = "music" if entry["generator"].startswith("ACE") else "sfx-preview"
        target_dir = DESTINATION / folder
        target_dir.mkdir(exist_ok=True)
        target = target_dir / source.name
        shutil.copy2(source, target)
        if folder == "music":
            ogg_source = ROOT / entry["ogg"]
            shutil.copy2(ogg_source, target.with_suffix(".ogg"))
            playable = target.with_suffix(".ogg")
            # Decode the delivery file too, so successful WAV generation cannot hide a broken OGG.
            subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-i", str(playable), "-f", "null", "-"], check=True)
            if entry.get("loop"):
                entry["loop_boundary_jump"] = float(np.max(np.abs(data[-1] - data[0])))
                assert entry["loop_boundary_jump"] < .05, f"Loop discontinuity: {source}"
        else:
            playable = target
        entry["file"] = target.relative_to(DESTINATION).as_posix()
        if "ogg" in entry:
            entry["ogg"] = playable.relative_to(DESTINATION).as_posix()
        label = html.escape(entry["label"])
        url = html.escape(playable.relative_to(DESTINATION).as_posix(), quote=True)
        looping = " loop" if entry.get("loop") else ""
        rows.append(f'<article><div><strong>{label}</strong><small>{entry["duration"]:.2f} s · {html.escape(entry["generator"])}</small></div><audio controls{looping} preload="none" src="{url}"></audio><a href="{url}" download>Pobierz</a></article>')
        report.append({"name": entry["name"], "group": entry["group"], "duration": len(data)/rate,
                       "allowed_duration": requirements[entry["group"]], "sample_rate": rate,
                       "format": "PCM_16", "peak": float(np.max(np.abs(data))), "valid": True})
    music_directory = ROOT / "art/audio/music"
    music_directory.mkdir(exist_ok=True)
    runtime_names = {"menu_grove_ambient": "menu_grove_acestep_v01.ogg", "battle_loop": "battle_acestep_v01.ogg"}
    runtime = {"music": {}, "stings": {}, "effect_groups": {}, "effect_files": {}}
    for entry in entries:
        if entry["generator"].startswith("ACE"):
            filename = runtime_names.get(entry["name"], entry["name"] + ".ogg")
            shutil.copy2(DESTINATION / entry["ogg"], music_directory / filename)
            path = "res://art/audio/music/" + filename
            if entry.get("loop"):
                runtime["music"]["menu" if entry["name"] == "menu_grove_ambient" else "battle"] = path
            else:
                runtime["stings"][entry["name"]] = path
        else:
            runtime["effect_groups"].setdefault(entry["group"], []).append(entry["name"])
            runtime["effect_files"][entry["name"]] = "res://art/audio/generated_complete/" + entry["file"]
    (music_directory / "catalog.json").write_text(json.dumps(runtime, ensure_ascii=False, indent=2), encoding="utf-8")
    licenses = DESTINATION / "licenses"
    licenses.mkdir(exist_ok=True)
    shutil.copy2(SOURCE / "environment.txt", DESTINATION / "environment.txt")
    shutil.copy2(ROOT / ".local-audio/ACE-Step-1.5/LICENSE", licenses / "ACE-Step-MIT.txt")
    shutil.copy2(ROOT / ".local-audio/AudioLDM/LICENSE", licenses / "AudioLDM-CC-BY-NC-SA-4.0.txt")
    provenance = {
        "ACE-Step": json.loads((ROOT / ".local-audio/ACE-Step-1.5/checkpoints/provenance.json").read_text()),
        "AudioLDM": json.loads((ROOT / ".local-audio/models/audioldm-s-full-v2/provenance.json").read_text()),
        "ACE-Step-code": subprocess.check_output(["git", "-C", str(ROOT / ".local-audio/ACE-Step-1.5"), "rev-parse", "HEAD"], text=True).strip(),
        "AudioLDM-implementation": "Official-author AudioLDM s-full-v2 checkpoint through diffusers.AudioLDMPipeline 0.37.1",
    }
    (DESTINATION / "manifest.json").write_text(json.dumps({"provenance": provenance, "assets": entries}, ensure_ascii=False, indent=2), encoding="utf-8")
    coverage = {group: [e["name"] for e in entries if e["group"] == group] for group in sorted(GROUPS)}
    (DESTINATION / "validation.json").write_text(json.dumps({"categories": len(coverage), "files": len(entries), "coverage": coverage, "checks": report}, indent=2), encoding="utf-8")
    (music_directory / "credits.json").write_text(json.dumps({"generator": "ACE-Step 1.5 turbo", "model": provenance["ACE-Step"],
            "tracks": [{"name": e["name"], "seed": e["seed"], "duration": e["duration"]} for e in entries if e["generator"].startswith("ACE")],
            "production_manifest": "art/audio/generated_complete/manifest.json"}, indent=2), encoding="utf-8")
    (DESTINATION / "README.txt").write_text(
        "SZEPT PERUNA — PAKIET AUDIO DO ODSŁUCHU\n\n"
        "Otwórz odsluch.html. Muzyka: ACE-Step 1.5 turbo, instrumentalna, WAV + OGG.\n"
        "Efekty: AudioLDM s-full-v2, dostarczone WAV 44,1 kHz PCM16, źródła modelu 16 kHz. Resampling nie dodaje nowego pasma.\n"
        "Modele i kod generatorów nie są dołączone do paczki.\n\n"
        "ACE-Step: model MIT; autorzy modelu deklarują możliwość komercyjnego użycia wygenerowanej muzyki.\n"
        "https://huggingface.co/ACE-Step/Ace-Step1.5\n"
        "AudioLDM: model CC BY-NC-SA 4.0, ograniczenie użytku komercyjnego. Efekty są podłączone wyłącznie w lokalnym uruchomieniu edytora, pomijane w eksporcie. Muzyka i sygnały ACE-Step działają też w eksporcie.\n"
        "https://huggingface.co/cvssp/audioldm-s-full-v2\n"
        "Autorzy AudioLDM: Haohe Liu i współautorzy, AudioLDM (ICML 2023), University of Surrey / CVSSP.\n"
        "Próbki zmieniono przez przycięcie, krótkie wygaszenie oraz normalizację.\n\n"
        "Kontrola techniczna: dekodowanie, długość, brak ciszy, wartości skończone, brak przesterowania.\n"
        "Nie oznacza to oceny odsłuchowej ani zatwierdzenia artystycznego. Parametry i identyfikatory modeli: manifest.json.\n"
        "Kompletność: 27 kategorii zgodnych z audio-assets-lista.md, 5 plików muzycznych i 45 efektów z wariantami. Szczegóły: validation.json.\n"
        "Pętle muzyczne: jednasekundowe przejście końca w początek; dopasowanie rytmiczne i artystyczne wymaga odsłuchu.\n"
        "Katalog .gdignore wyłącza te próbki z importu i eksportu Godot.\n", encoding="utf-8")
    page = '''<!doctype html><html lang="pl"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Szept Peruna — odsłuch</title>
<style>body{margin:0;background:#10261f;color:#f5ebd2;font:16px/1.6 system-ui}main{max-width:920px;margin:auto;padding:36px 24px}h1{font-size:36px;margin-bottom:8px}p{color:#c6d1bf}.note{padding:16px;border:1px solid #ae915b;border-radius:12px}article{display:flex;align-items:center;gap:18px;padding:18px 0;border-bottom:1px solid #365044}article div{flex:1}small{display:block;color:#b8c6b2}a{color:#efd197}audio{width:300px;max-width:100%}@media(max-width:700px){article{align-items:flex-start;flex-direction:column}}</style>
<main><h1>Szept Peruna</h1><p>Pełna rozpiska: 27 kategorii, 5 plików muzycznych i 45 efektów. ACE-Step 1.5 oraz AudioLDM.</p><p class="note">Muzyka i sygnały ACE-Step działają w grze. Efekty AudioLDM są podłączone lokalnie w edytorze i pomijane w eksporcie: model ma licencję CC BY-NC-SA 4.0 z ograniczeniem użytku komercyjnego. Wszystkie WAV: 44,1 kHz, PCM16.</p>'''
    (DESTINATION / "odsluch.html").write_text(page + "\n".join(rows) + '</main></html>', encoding="utf-8")
    archive = DESTINATION.parent / "szept-peruna-audio-complete.zip"
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as zipped:
        for path in DESTINATION.rglob("*"):
            if path.is_file() and path.name != ".gdignore":
                zipped.write(path, path.relative_to(DESTINATION))
    print(json.dumps({"assets": len(entries), "preview": str(DESTINATION / "odsluch.html"), "zip": str(archive), "bytes": archive.stat().st_size}, ensure_ascii=False))


if __name__ == "__main__":
    main()
