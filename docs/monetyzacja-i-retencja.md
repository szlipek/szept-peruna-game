# Monetyzacja i powroty do gry

## Decyzja dla obecnej wersji

- Bez banerów i reklam przy uruchomieniu gry.
- Pierwsze pięć poziomów kampanii jest bez reklam. Później reklama pełnoekranowa może pojawić się po naturalnej przerwie: po zwycięstwie, przed kolejnym poziomem. Pokazuje się po każdych czterech wygranych, maksymalnie dwa razy na dobę.
- Od szóstego poziomu dostępna jest jedna dobrowolna reklama nagradzana na dobę: po zwycięstwie daje dodatkowe 50% monet z nagrody. Nagroda pojawia się dopiero po potwierdzeniu jej przez SDK.
- Reklamy nie są wymagane do ukończenia poziomu. Brak reklamy lub internetu nie zatrzymuje kampanii.
- Ekran końca poziomu oferuje reklamę tylko wtedy, gdy SDK ma już załadowaną reklamę. Nie wyświetlamy pustego albo niedziałającego przycisku.

W kodzie limity są zapisane lokalnie razem z postępem gracza. Są więc limitami dla jednej instalacji, a nie zabezpieczeniem przed manipulacją; do wiarygodnych limitów na wielu urządzeniach potrzebny byłby serwer.

## Co już jest w projekcie

`addons/AdmobPlugin` zawiera oficjalny plugin Godot AdMob 5.3. `scenes/puzzle_level.tscn` używa testowego identyfikatora aplikacji Androida, a `is_real` pozostaje wyłączone. `scripts/game_ads.gd` obsługuje zgodę UMP, ładowanie, emisję i błędy reklam. `scripts/puzzle_level.gd` stosuje limity, zapisuje je i przyznaje bonus po sygnale nagrody.

Konfiguracja używa testowych identyfikatorów Google i nie generuje przychodu. Żeby uruchomić produkcyjne reklamy, właściciel musi utworzyć aplikację i jednostki reklamowe w AdMob, skonfigurować wymagane komunikaty prywatności, wpisać identyfikator aplikacji oraz jednostki interstitial i rewarded w węźle `Admob`, a następnie włączyć `is_real`. Nie należy używać prawdziwych jednostek podczas testowania. Przed publikacją trzeba również zaktualizować politykę prywatności i deklarację Google Play Data safety.

## Powody, by wrócić do gry

W grze działają już łagodniejszy początek kampanii, premie za synergie składu, dziennik bestii z nagrodą za odkrycie krainy oraz trzy rodzaje opcjonalnych celów walki. Cele dają nagrody tylko za pierwsze zaliczenie na danym poziomie.

Kolejne rozsądne rozszerzenia:

1. **Krótkie cele dzienne** — trzy proste zadania, np. wygraj dwie walki, użyj wody pięć razy, ulepsz budynek. Nagradzaj walutą zdobytą w grze, bez kar za opuszczony dzień.
2. **Wydarzenia bez presji czasu** — dodatkowe walki można rozpocząć w dowolnym momencie; nie odbierają nagród za nieobecność.

Synergie warto dalej rozwijać przez czytelne opisy premii na kartach składu. Przy nowych celach i wydarzeniach należy utrzymać podstawową zasadę: kampanię zawsze wygrywa się przez pokonanie wrogów.

## Zależności i źródła

- Plugin: [Godot AdMob, wydania](https://github.com/godot-sdk-integrations/godot-admob/releases). Wersja 5.3 jest przeznaczona dla Godot 4.5.x.
- [Reklamy pełnoekranowe — wskazówki Google](https://developers.google.com/admob/android/interstitial): umieszczaj je w naturalnych przerwach i używaj jednostek testowych podczas developmentu.
- [Google Mobile Ads SDK — rozpoczęcie](https://developers.google.com/admob/android/quick-start): wymagania integracji i prywatności.
- Warunki użycia pluginu są w `addons/AdmobPlugin/LICENSE`.
