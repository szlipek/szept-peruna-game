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
