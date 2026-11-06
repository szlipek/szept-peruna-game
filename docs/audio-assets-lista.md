# Lista muzyki i dźwięków do „Szeptu Peruna”

Lista opisuje oprawę audio potrzebną do podstawowej wersji gry. Czasy są orientacyjne. Dźwięki powinny pasować do słowiańskiego świata fantasy: naturalne, leśne i lekko tajemnicze, z czytelnym, krótkim atakiem. Bez nowoczesnych syntezatorów, chyba że są użyte subtelnie jako magiczny akcent.

## Muzyka

| Priorytet | Plik / zastosowanie | Brzmienie i nastrój | Długość |
|---|---|---|---:|
| P1 | `menu_grove_ambient` — menu i osada | Spokojny leśny ambient, ciepłe smyczki, dyskretna lira lub cytra, rzadkie dzwonki i miękki wiatr. Bez mocnej melodii, żeby nie męczył przy dłuższym przeglądaniu menu. | 60–90 s, płynna pętla |
| P1 | `battle_loop` — walka | Żywsze bębny obręczowe, niskie smyczki i oszczędny motyw inspirowany muzyką słowiańską. Utrzymuje napięcie, ale zostawia miejsce na efekty kafelków i ataków. | 75–120 s, płynna pętla |
| P2 | `victory_sting` — zwycięstwo | Krótki triumfalny motyw z bębnem, smyczkami i jasnym dźwiękiem dzwonu. | 3–5 s |
| P2 | `defeat_sting` — porażka | Krótki, łagodnie opadający motyw; smyczki i niski bęben. Ma sygnalizować porażkę, ale nie brzmieć przygnębiająco ani karząco. | 3–5 s |
| P3 | `village_upgrade_sting` — rozbudowa osady | Ciepły, podnoszący na duchu motyw z drewnianym stukiem, dzwonkiem i krótkim narastaniem. | 2–4 s |

## Efekty interfejsu i nagród

| Priorytet | Plik / zastosowanie | Brzmienie | Długość |
|---|---|---|---:|
| P1 | `ui_click` — zwykły przycisk | Cichy, krótki drewniany klik z delikatnym metalicznym detalem. | 0,08–0,2 s |
| P1 | `ui_confirm` — potwierdzenie, wybór | Jasny, przyjemny dźwięk liry lub małego dzwonka. | 0,3–0,7 s |
| P1 | `ui_back` — powrót / anulowanie | Krótkie, miękkie zejście tonu. | 0,2–0,5 s |
| P2 | `resource_coin` — monety | Dwa lub trzy lekkie metaliczne brzęknięcia, bez ostrego, wysokiego pisku. | 0,4–0,8 s |
| P2 | `resource_wood` — drewno | Krótki stuk drewna i szelest. | 0,3–0,7 s |
| P2 | `resource_perun` — moc / iskry Peruna | Krótki magiczny błysk: jasny dzwonek i kontrolowany trzask iskry. | 0,4–0,9 s |
| P2 | `chest_open` — otwarcie skrzyni | Zamek, skrzypnięcie wieka i krótki blask nagrody. Zostawić miejsce na osobne dźwięki zdobywanych zasobów. | 0,8–1,5 s |
| P2 | `reward_reveal` — pokazanie nagrody | Krótki, radosny akcent; wariant zwykły i rzadszy mogą różnić się wysokością lub dodatkowym dzwonkiem. | 0,5–1,2 s |
| P3 | `level_unlock` — odblokowanie poziomu / funkcji | Krótki sygnał odkrycia z narastającym dzwonkiem. | 0,8–1,5 s |

## Walka i układanie kafelków

| Priorytet | Plik / zastosowanie | Brzmienie | Długość |
|---|---|---|---:|
| P1 | `tile_select` — zaznaczenie kafelka | Cichy, krótki klik dopasowany do materiału magicznego kamienia. | 0,08–0,18 s |
| P1 | `tile_swap` — zamiana kafelków | Krótki przesuw z lekkim magicznym szelestem. | 0,15–0,35 s |
| P1 | `match_3` — dopasowanie trzech znaków | Trzytonowy, satysfakcjonujący błysk. | 0,35–0,7 s |
| P2 | `match_4_5` — większe dopasowanie | Mocniejsza, bogatsza wersja dopasowania, z krótkim narastaniem. | 0,5–1 s |
| P2 | `tile_cascade` — kolejne dopasowanie / opadanie | Krótkie, lekkie dźwięki spadających znaków; przygotować 3–5 wariantów do losowania. | 0,15–0,4 s każdy |
| P1 | `hero_attack` — atak bohatera | Zależny od bohatera: np. cięcie, uderzenie młota, strzał lub magia. Przygotować kilka różniących się wariantów. | 0,4–1 s |
| P1 | `enemy_attack` — atak wroga | Cięższy, organiczny atak z krótkim ruchem powietrza; warianty dla różnych typów wrogów. | 0,4–1 s |
| P1 | `hit_impact` — trafienie | Krótki, wyraźny kontakt z ciałem, zbroją lub tarczą; 2–4 warianty. | 0,15–0,45 s |
| P1 | `hero_hurt` — obrażenia bohatera | Krótki, stłumiony sygnał bólu lub uderzenia, bez krzyku dominującego nad grą. | 0,25–0,6 s |
| P2 | `heal` — leczenie | Ciepłe, spokojne dźwięki wody i dzwonka. | 0,5–1 s |
| P2 | `skill_activate` — umiejętność | Osobny, charakterystyczny efekt dla każdej rodziny mocy; np. piorun, korzenie, wiatr lub woda. | 0,6–1,5 s |
| P2 | `enemy_defeated` — pokonanie wroga | Krótki, czytelny finał dopasowany do rodzaju przeciwnika; bez długiego odgłosu śmierci. | 0,4–1 s |
| P3 | `turn_start` — początek tury gracza | Subtelny sygnał, który nie konkuruje z muzyką i tutorialem. | 0,2–0,5 s |

## Wskazówki do przygotowania plików

- Efekty: WAV, mono lub stereo, 44,1 kHz, 16-bit PCM; krótkie pliki można później skompresować w Godot.
- Muzyka: WAV jako plik źródłowy; do gry można użyć OGG, jeśli ważny jest rozmiar paczki.
- Ambient i muzyka walki powinny zapętlać się bez słyszalnego skoku. Zostaw krótki fade-in/fade-out albo dopasuj początek i koniec fali.
- Krótkie efekty powinny mieć czysty początek bez niepotrzebnej ciszy i naturalny, krótki zanik.
- Przygotuj po kilka wariantów dla często powtarzanych akcji, takich jak trafienia, kliknięcia kafelków i ataki, aby ograniczyć monotonię.
- Zostaw headroom: bez przesterowania i bez masteringu tak głośnego, by efekty zagłuszały muzykę.
- Każdy plik powinien mieć osobny ślad praw do użycia/licencji, jeśli powstał w zewnętrznym generatorze.

## Kolejność produkcji

1. **Pierwszy pakiet:** ambient menu/osady, muzyka walki, klik, potwierdzenie, zamiana i dopasowanie kafelków, atak bohatera i wroga, trafienie, zwycięstwo i porażka.
2. **Nagrody i rozwój:** monety, drewno, moc Peruna, otwieranie skrzyni, pokaz nagrody, ulepszenie bohatera i rozbudowa osady.
3. **Rozszerzenia:** warianty ataków i trafień, efekty poszczególnych umiejętności, odblokowanie poziomu i dodatkowe motywy muzyczne.

## Już przygotowany plik

- `art/audio/menu_grove_ambient_v01.wav` — proceduralny ambient menu/osady, 60 sekund, stereo, 44,1 kHz, WAV PCM16. Jest to punkt wyjścia do odsłuchu i dalszego dostrojenia.

## Kompletny pakiet ACE-Step 1.5 i AudioLDM — 6 listopada 2026

Przygotowano **50 plików w 27 kategoriach** z trzech powyższych tabel: 5 muzycznych oraz 45 efektów z wariantami. Wszystkie dostarczone WAV mają 44,1 kHz, 16-bit PCM. Muzyka i sygnały mają dodatkowe OGG. Menu: 64 s, walka: 80 s, zwycięstwo i porażka: po 4 s, rozbudowa: 3 s.

- Odsłuch: [odsluch.html](../art/audio/generated_complete/odsluch.html).
- Paczka: [szept-peruna-audio-complete.zip](../art/audio/szept-peruna-audio-complete.zip).
- Opisy, ziarna, licencje, sumy kontrolne i rewizje modeli: [manifest.json](../art/audio/generated_complete/manifest.json).
- Kontrola każdej pozycji względem tabel tego dokumentu: [validation.json](../art/audio/generated_complete/validation.json).
- Katalog produkcji: `tools/audio_catalog.py`; generowanie: `tools/generate_game_audio.py`; kontrola, pakowanie i instalacja: `tools/package_game_audio.py`.

### Pokrycie rozpiski

| Pozycja | Liczba plików | Długości [s] |
|---|---:|---|
| `ui_click` | 3 | 0,14, 0,16, 0,18 |
| `ui_confirm` | 1 | 0,55 |
| `ui_back` | 1 | 0,35 |
| `resource_coin` | 1 | 0,65 |
| `resource_wood` | 1 | 0,5 |
| `resource_perun` | 1 | 0,7 |
| `chest_open` | 1 | 1,25 |
| `reward_reveal` | 2 | 0,75, 1,05 |
| `level_unlock` | 1 | 1,15 |
| `tile_select` | 3 | 0,11, 0,13, 0,15 |
| `tile_swap` | 1 | 0,28 |
| `match_3` | 1 | 0,6 |
| `match_4_5` | 1 | 0,85 |
| `tile_cascade` | 4 | 0,19, 0,23, 0,27, 0,31 |
| `hero_attack` | 4 | 0,8 |
| `enemy_attack` | 3 | 0,85 |
| `hit_impact` | 3 | 0,32 |
| `hero_hurt` | 1 | 0,4 |
| `heal` | 1 | 0,9 |
| `skill_activate` | 7 | 1,15 |
| `enemy_defeated` | 3 | 0,8 |
| `turn_start` | 1 | 0,3 |
| `menu_grove_ambient` | 1 | 64,0 |
| `battle_loop` | 1 | 80,0 |
| `victory_sting` | 1 | 4,0 |
| `defeat_sting` | 1 | 4,0 |
| `village_upgrade_sting` | 1 | 3,0 |

Są 3 warianty kliknięcia, 3 zaznaczenia kafelka, 4 kaskady, 4 ataki bohaterów (łuk, młot, ostrze, magia), 3 ataki wrogów, 3 trafienia (ciało, zbroja, tarcza), 2 odkrycia nagrody oraz 3 pokonania wroga. Umiejętności mają 7 rodzin: piorun, korzenie, wiatr, woda, ogień, runy i bursztyn.

### Podłączenie i miks

`scripts/game_audio.gd` przełącza zapętlone menu/osadę i walkę z przejściem 0,8 s. Trzy sygnały ACE-Step odtwarzają się przy zwycięstwie, porażce i rozbudowie; muzyka w ich trakcie jest ściszana. Osiem głosów i odstęp między powtórzeniami ograniczają nakładanie efektów. Warianty nie powtarzają się bezpośrednio po sobie, a osobny generator losowy nie wpływa na planszę. Przycisk „USTAWIENIA” w menu otwiera osobne przełączniki dźwięków, muzyki i wibracji. Wyłączenie dźwięków zatrzymuje efekty oraz usuwa ich kolejkę, a muzyka ma niezależne wyciszenie. Krótkie sygnały zwycięstwa, porażki i rozbudowy są efektami; przełącznik muzyki dotyczy tła. Wszystkie trzy ustawienia są zapisywane. Stare wyciszenie całości jest zachowane przy migracji zapisu. Rozpoczęcie nowej walki usuwa stare oczekujące efekty.

Rodzaj ataku i umiejętności jest dobierany dla wszystkich 25 bohaterów. Rodzaje przeciwników korzystają z odgłosów organicznych, duchów i kamienia. Skrzynia, odkrycie nagrody i monety są odtwarzane kolejno. Podłączono także wybór kafelka, kaskady, obrażenia bohatera, pokonanie wroga, początek tury, drewno, Iskry Peruna i odblokowanie etapu.

### Licencje i ograniczenia

ACE-Step 1.5 turbo: model MIT; autorzy deklarują możliwość komercyjnego używania wygenerowanej muzyki: https://huggingface.co/ACE-Step/Ace-Step1.5. Pięć OGG znajduje się w `art/audio/music/` i jest dostępnych także w eksporcie.

AudioLDM s-full-v2: model CC BY-NC-SA 4.0 z ograniczeniem użytku komercyjnego: https://huggingface.co/cvssp/audioldm-s-full-v2. Efekty działają wyłącznie w lokalnym uruchomieniu za pomocą binarium edytora Godot. `.gdignore`, ustawienia eksportu i warunek w kodzie pomijają je w szablonach eksportowych, także debug APK. Tam działa zastępczy ton proceduralny. Modele znajdują się w ignorowanym katalogu `.local-audio/` i nie trafiają do gry.

AudioLDM generuje źródła 16 kHz. Dostarczone WAV zostały przeliczone do wymaganych 44,1 kHz; zmiana częstotliwości próbkowania nie dodaje pasma ani szczegółów. Zachowano naturalne krótkie zaniki oraz zapas głośności. Gotowe pętle mają przejście końca w początek, a ich skok między próbkami jest sprawdzany.

### Weryfikacja

Automatycznie sprawdzono: obecność wszystkich 27 kategorii, warianty, długości zgodne z oryginalnymi tabelami, WAV 44,1 kHz PCM16, dekodowanie OGG, wartości skończone, brak ciszy i przesterowania oraz przejścia pętli. Test `tests/game_audio_test.gd` obejmuje 45 efektów, 3 sygnały, mapowanie wszystkich 25 bohaterów, warianty, przełączanie muzyki, wyciszenie, kolejkę i tryb eksportowy. Przeszły również testy rozwoju osady i regresji działania gry.

Kontrola techniczna nie zastępuje odsłuchu artystycznego. Strona odsłuchowa pozwala ocenić brzmienie, naturalność i rytmiczne przejścia; takiej oceny nie oznaczono jako wykonanej.

### Wibracje

Nieudana zamiana kafelków, która nie tworzy dopasowania, uruchamia impuls 55 ms na Androidzie i iOS. Odstęp między impulsami wynosi co najmniej 250 ms. Ustawienie wibracji jest niezależne od audio; zwykłe ruchy, trafienia i kaskady nie wibrują. Eksport Androida ma włączone uprawnienie VIBRATE. Testy sprawdzają wywołanie sterownika, wyłączenie i zapis preferencji; fizyczne odczucie wymaga sprawdzenia na urządzeniu.
