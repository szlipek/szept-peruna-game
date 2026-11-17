# Szept Peruna — lista przed Google Play

Stan prac: projekt przygotowawczy, bez publikacji. Wydawca: SP-Media Przemysław Szliep, kontakt `biuro@spmedia.pl`. Planowana grupa odbiorców: nastolatki i dorośli; odpowiednie przedziały i ocenę treści należy określić w Play Console zgodnie z faktyczną zawartością i rynkami.

## Przygotowane

- Aplikacja Firebase Android `org.szeptperuna.game`; statystyki i raporty awarii są domyślnie wyłączone.
- Presety Android i Android AAB z target SDK 36 oraz lokalny skrypt przygotowania szablonu Gradle. Debug APK dla API 36 powstał i został sprawdzony pod kątem pakietu, target SDK i zasobów.
- Testowy AAB `tmp/SzeptPeruna-API36-test.aab` jest niepodpisany i nie nadaje się do wydania. W archiwum moduł bazowy zajmuje około 62 MiB, a pakiet zasobów instalacyjnych około 640 MiB po kompresji ZIP; wynik ten nie jest wyliczonym przez Play rozmiarem pobierania.
- Lokalny klucz upload i plik hasła znajdują się w ignorowanym przez Git katalogu `.local-signing/`. Przywrócono dostęp właścicielowi i sprawdzono, że klucz otwiera się zapisanym hasłem. Zrobić bezpieczną kopię zapasową obu plików; nie przekazywać hasła w rozmowie.
- Zdarzenia postępu, rozwoju bohaterów i osady oraz oddzielne przełączniki prywatności.
- Pięć wstępnych zrzutów 1080 × 1920 z silnika w `docs/google-play-zrzuty-hd/`, szkic karty sklepu i polityki prywatności. Przygotowano grafikę promocyjną 1024 × 500 oraz ikonę sklepu 512 × 512 w `docs/google-play-grafika/`.
- Przygotowany przycisk ustawień prywatności UMP, jeżeli Google wymaga jego pokazania. Ruch reklamowy pozostaje testowy.

## Do wykonania przed wydaniem

1. Skonfigurować konto i aplikację AdMob oraz właściwe identyfikatory aplikacji, reklamy pełnoekranowej i reklamy za nagrodę. Skonfigurować komunikaty prywatności Google i sprawdzić je przed włączeniem reklam produkcyjnych.
2. Na rzeczywistych urządzeniach przetestować grę, Android 16 i wyświetlanie krawędzi, zapis offline, reklamy testowe, zgodę i zmianę wyboru, Analytics DebugView oraz testową awarię Crashlytics. Sprawdzić raporty awarii natywnych oraz symbole.
3. Dokończyć i opublikować politykę prywatności pod publicznym adresem: potwierdzić usługi, okresy retencji i przekazywanie danych. Na podstawie faktycznej konfiguracji SDK wypełnić deklaracje Play Console, w tym Data safety, reklamy, grupę docelową i ankietę oceny treści.
4. Zweryfikować prawa i licencje wszystkich zasobów, sprawdzić materiały karty sklepowej oraz porównać zrzuty z finalną wersją Androida.
5. Bezpiecznie zarchiwizować klucz upload razem z hasłem. Zbudować **wydawniczy podpisany AAB** z presetu `Android AAB`; nie wysyłać niepodpisanego pakietu testowego jako wydania. Ocenić rozmiar pobierania i rozkład modułów w Play Console — rozmiar APK nie jest wynikiem pomiaru Play.
6. Utworzyć konfigurację aplikacji i wymagane testy w Play Console. Jeśli konto podlega warunkom Google dla nowych kont osobistych, wymagany jest test zamknięty z co najmniej 12 testerami uczestniczącymi przez 14 kolejnych dni, a następnie wniosek o dostęp do produkcji.

Odnośniki: https://support.google.com/googleplay/android-developer/answer/11926878, https://support.google.com/googleplay/android-developer/answer/14151465, https://support.google.com/googleplay/android-developer/answer/9859372.
