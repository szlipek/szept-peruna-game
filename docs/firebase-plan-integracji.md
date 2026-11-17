# Firebase — zakres integracji Szeptu Peruna

Stan: integracja w przygotowaniu. Kod zdarzeń i przełączników jest dodany, lecz do potwierdzenia działania potrzebny jest eksport Androida i test na urządzeniu. Bez natywnego dostawcy gra nie wysyła zdarzeń.

## Zdarzenia rozgrywki

Parametry są identyfikatorami elementów gry lub liczbami; nie zawierają nazwy gracza, treści zapisu ani danych kontaktowych. Rejestrujemy zdarzenie po rzeczywistym wykonaniu akcji, nie przy samym otwarciu przycisku.

| Zdarzenie | Parametry | Zastosowanie |
| --- | --- | --- |
| `level_start` | `level_name`, `mode` | Liczba prób i ścieżka kampanii. |
| `level_end` | `level_name`, `mode`, `success`, `duration_seconds`, `moves`, `stars` | Odsetek zwycięstw, trudne etapy i długość walk. |
| `hero_upgrade` | `hero_id`, `hero_level` | Popularność i tempo rozwoju postaci. |
| `hero_recruited` | `hero_id` | Rekrutacje opłacone w panelu drużyny. |
| `talent_upgrade` | `hero_id`, `branch`, `tier` | Wybory na drzewku talentów. |
| `party_changed` | `hero_1`, `hero_2`, `hero_3` | Popularne składy; puste miejsca mają wartość `none`. |
| `building_upgrade` | `building_id`, `building_level` | Rozwój osady. |
| `tutorial_complete` | `tutorial_id` | Ukończenie pierwszej walki samouczka. |
| `rewarded_ad_result` (planowane) | `placement`, `result` | Zainteresowanie reklamą i rzeczywiste przyznanie nagrody. |

W raportach należy porównywać rozpoczęcia i zakończenia poziomów, procent wygranych, czas i liczbę prób, wybory bohaterów i talentów oraz powroty graczy w kolejnych dniach. Niedokończona walka nie musi oznaczać porażki: gracz mógł zamknąć grę albo utracić połączenie. Parametry wymagające raportowania jako wymiary niestandardowe trzeba osobno zarejestrować w Analytics; istnieją limity liczby wymiarów.

Nie wysyłać zdarzenia po każdym ruchu ani całej zawartości zapisu. Analityka i raportowanie awarii muszą mieć osobne, czytelne ustawienia zbierania danych i rzeczywistą obsługę zgody lub innej odpowiedniej podstawy przed ich uruchomieniem.

## Zapis gry

Zgodnie z wyborem właściciela nie wdrażamy logowania ani zapisu w chmurze. Postęp pozostaje lokalny na urządzeniu.

## Raporty awarii

Crashlytics wymaga natywnego SDK, konfiguracji Gradle i testowego raportu na urządzeniu. Ponieważ gra używa silnika z kodem natywnym, należy osobno zweryfikować obsługę awarii natywnych i symboli; raporty Java/Kotlin nie dowodzą automatycznie czytelności błędów silnika. Nie dodawać do raportów zawartości zapisu ani danych konta.
