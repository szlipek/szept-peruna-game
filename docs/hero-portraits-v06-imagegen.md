# Portrety bohaterów v06 — ImageGen

Wygenerowano 25 indywidualnych grafik wbudowanym ImageGen, po jednej na bohatera. PNG RGBA, 1254 × 1254, przezroczyste tło. Referencją każdego wywołania był odpowiadający portret v05. Pliki końcowe: `art/characters/hero_<id>_portrait_v06.png`.

Wspólny prompt:

```text
Use case: identity-preserve. Asset type: standalone transparent square half-bust character portrait for the Slavic fantasy game Szept Peruna. Regenerate this ONE referenced hero as a polished new illustration. Keep the same recognizable face, age, gender, hairstyle, clothing palette, Slavic embroidered costume and signature magical equipment. Match the reference's detailed realistic fantasy rendering. Composition: square canvas, head and shoulders and only upper chest, NOT waist, hips, legs or full body. Face large and readable; all silhouette contained inside canvas with generous transparent margin on every side. The lower silhouette MUST be a finished organic garment edge: layered curved overlapping cloak folds, irregular leaf-shaped fabric tips, fringe and embroidery tapering naturally around the bust, forming an asymmetric rounded silhouette. No straight horizontal or vertical crop edges, no rectangular image/backdrop, no severed arms. Hands/equipment if present must be compact at upper chest and fully contained. Show a short mantle/shoulder cape that really ends inside the image instead of truncating the body. Character isolated on real transparent alpha background, no scene, no floor, no frame, no text, no watermark. Keep face and costume bright enough to read on a dark green UI. Individual asset only, no sheet.
```

Dla bohaterów poza Ladą, Brunem i Miętą dodano:

```text
Important: leave 5% transparent padding around the entire finished silhouette, including weapon, hair and cloak. Nothing touches any canvas border. The framing ends just below upper chest.
```

| Bohater (ID) | Dopisek do promptu | Plik ImageGen |
| --- | --- | --- |
| lada | Hero: Lada, oak grove archer. | exec-76f811f1-7d8f-4ab6-8c52-aa5dffbf39f3.png |
| brun | Hero ID: brun. | exec-9ed58e1b-fcac-4614-99d4-23900bc5768d.png |
| mieta | Hero ID: mieta. | exec-98ae0036-34ba-41f5-b325-ee084d4dd929.png |
| wszebor | Hero: wszebor. | exec-25ec6e6d-43c9-4861-b5de-4c056ce038f2.png |
| boruta | Hero: boruta. | exec-fd72862d-f454-4ca4-8ca7-052407191a67.png |
| dobromir | Hero: dobromir. | exec-2352866d-4ff1-45f3-b34d-270f966750aa.png |
| milena | Hero: milena. | exec-feec033f-b2bb-41dd-a850-2f6fa16a3ea6.png |
| radomir | Hero: radomir. | exec-fd69ea15-ea36-41b7-bf75-1a5465e121c2.png |
| witosz | Hero: witosz. | exec-337516b0-e840-4141-9421-43f07b1c0eab.png |
| jagna | Hero: jagna. | exec-b7e5db2f-4f1c-416b-aeb8-bd85bde05984.png |
| rada | Hero: rada. | exec-596a9cd3-568d-4821-884f-f40a401a4cbb.png |
| welesa | Hero: welesa. | exec-9c29ddbb-af03-4a90-a6f5-ecd8c7896ecb.png |
| zorya | Hero: zorya. | exec-42a043e7-d960-4f05-bb31-fcc69f54a4fb.png |
| jaromir | Hero: jaromir. | exec-68f1cf18-53b4-4ac4-9c05-f054e23c4087.png |
| msciwoj | Hero: msciwoj. | exec-48f805ee-236c-4bd7-a836-fd833baa4e3c.png |
| dobrawa | Hero: dobrawa. | exec-3f911581-8924-4edf-9795-66fdfded72b1.png |
| perunika | Hero: perunika. | exec-933c0499-6459-408b-9806-7204ad83222f.png |
| czernik | Hero: czernik. | exec-246c897e-6915-4770-8ab9-ae6cb8203675.png |
| mirka | Hero: mirka. | exec-07851261-52c9-4b64-8c30-5b91a6efb6dd.png |
| wlodzimierz | Hero: wlodzimierz. | exec-958b21c8-c7cc-4551-a282-6c5ca4ee9e53.png |
| zywia | Hero: zywia. | exec-aa4b0df3-ece2-4cbe-afba-ef1a7c86dc43.png |
| mokosza | Hero: mokosza. | exec-678efb26-616c-45da-8930-0d554e30e097.png |
| stribog | Hero: stribog. | exec-869ba2e0-7502-441d-badc-d381ef36e06f.png |
| swarog | Hero: swarog. | exec-68408993-2ddc-4394-b336-23fae01e1cbb.png |
| weles | Hero: weles. | exec-8226e52c-cac6-4083-b5c1-ee962eb475bc.png |

Integracja: cała grafika wyświetlana w menu Drużyna i wymiany składu. Usunięto prostokątne kadrowanie półpiersia i wspólną nakładkę płaszcza. Naturalny obrys jest częścią każdego wygenerowanego portretu. Podglądy można odtworzyć poleceniem `Godot --path . --script tools/capture_hero_portraits.gd --audio-driver Dummy`.

