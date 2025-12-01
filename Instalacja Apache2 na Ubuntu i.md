# Instalacja Apache2 na Ubuntu i wdrożenie prostej wizytówki HTML/CSS

**Cel lekcji:** Uczniowie zainstalują serwer Apache2 na Ubuntu, skonfigurują katalog dokumentów i wdrożą prostą statyczną wizytówkę HTML/CSS, jakby to robił administrator systemu.
***

## 1. Wprowadzenie i teoria (30 min)

### Co to jest serwer WWW i Apache?

- Serwer WWW (np. Apache) to usługa, która nasłuchuje na porcie (domyślnie 80) i wysyła pliki HTML, CSS, JS, obrazy do przeglądarki klienta.
- Apache2 to jeden z najpopularniejszych serwerów WWW, działa na Linuxie (Ubuntu, Debian, CentOS) i obsługuje strony statyczne (HTML/CSS) oraz dynamiczne (PHP).


### Typowy workflow administratora

1. Instalacja Apache2 z repozytorium systemu.
2. Sprawdzenie działania (strona domyślna Apache).
3. Ustawienie katalogu dokumentów (np. `/var/www/wizytowka`).
4. Wdrożenie plików HTML/CSS do katalogu.
5. Testowanie w przeglądarce (localhost lub adres IP).

### Przykład wizytówki – „O mnie”

Zaproponuj prostą wizytówkę typu „O mnie”:

- Tytuł: „Moja wizytówka – [Imię]”
- Nagłówek: imię i nazwisko, zdjęcie (opcjonalnie).
- Sekcje:
    - O mnie (krótki opis).
    - Technologie (np. HTML, CSS, Linux).
    - Kontakt (e‑mail, telefon).
- Styl: proste kolory, czytelna czcionka, bez responsywności (dla uproszczenia).

***

## 2. Laboratorium – krok po kroku (50 min)

### Przygotowanie (5 min)

- Uczniowie uruchamiają maszynę wirtualną z Ubuntu Server/Desktop (20.04 lub 22.04).
- Sprawdzają połączenie sieciowe: `ip a` lub `ip addr show` – zapisują adres IP (np. `192.168.1.100`).

***

### Krok 1: Instalacja Apache2 (10 min)

**Zadanie:** Zainstalować Apache2 i sprawdzić usługę.

**Kroki (nauczyciel pokazuje na rzutniku, uczniowie powtarzają):**

```bash
# 1. Aktualizacja list pakietów
sudo apt update

# 2. Instalacja Apache2
sudo apt install -y apache2

# 3. Sprawdzenie statusu usługi
sudo systemctl status apache2

# 4. Włączenie Apache2 przy starcie systemu
sudo systemctl enable apache2
```

**Co sprawdzić:**

- W terminalu: `active (running)` w statusie.
- W przeglądarce: `http://localhost` lub `http://<adres_IP>` – powinna być strona „Apache2 Ubuntu Default Page”.

***

### Krok 2: Konfiguracja katalogu dokumentów (10 min)

**Zadanie:** Utworzyć katalog dla wizytówki i ustawić go jako główny dokument.

**Kroki:**

```bash
# 1. Utworzenie katalogu dla wizytówki
sudo mkdir -p /var/www/wizytowka

# 2. Ustawienie właściciela (dla bezpieczeństwa)
sudo chown -R $USER:$USER /var/www/wizytowka

# 3. Ustawienie uprawnień
sudo chmod -R 755 /var/www/wizytowka

# 4. Edycja domyślnego VirtualHost (opcjonalnie – dla zaawansowanych)
sudo nano /etc/apache2/sites-available/000-default.conf
```

**W pliku `000-default.conf` zmienić:**

```apache
DocumentRoot /var/www/wizytowka
```

**Po zmianie:**

```bash
# 5. Restart Apache2
sudo systemctl restart apache2
```

**Co sprawdzić:**

- W przeglądarce: `http://localhost` – teraz powinno być „Forbidden” (bo katalog jest pusty)

***

### Krok 3: Tworzenie wizytówki HTML/CSS (15 min)

**Zadanie:** Utworzyć prostą wizytówkę w katalogu `/var/www/wizytowka`.

**Krok 3.1: Plik `index.html`**

```bash
nano /var/www/wizytowka/index.html
```

**Przykładowa zawartość (uczniowie mogą modyfikować imię, opis itp.):**

```html
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Moja wizytówka – Jan Kowalski</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Jan Kowalski</h1>
        <p>Technik informatyk</p>
    </header>

    <main>
        <section>
            <h2>O mnie</h2>
            <p>Uczę się administracji systemami Linux i tworzenia stron internetowych. Interesuję się sieciami komputerowymi i bezpieczeństwem IT.</p>
        </section>

        <section>
            <h2>Technologie</h2>
            <ul>
                <li>HTML / CSS</li>
                <li>Linux (Ubuntu, Debian)</li>
                <li>Apache, MySQL</li>
            </ul>
        </section>

        <section>
            <h2>Kontakt</h2>
            <p>E‑mail: jan.kowalski@example.com</p>
            <p>Telefon: 123 456 789</p>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 Moja wizytówka</p>
    </footer>
</body>
</html>
```

**Krok 3.2: Plik `style.css`**

```bash
nano /var/www/wizytowka/style.css
```

**Przykładowy styl:**

```css
body {
    font-family: Arial, sans-serif;
    background-color: #f4f4f4;
    color: #333;
    margin: 0;
    padding: 20px;
}

header {
    text-align: center;
    margin-bottom: 30px;
}

header h1 {
    color: #0073e6;
}

main section {
    margin-bottom: 20px;
}

footer {
    text-align: center;
    margin-top: 30px;
    color: #666;
}
```


***

### Krok 4: Testowanie i weryfikacja (10 min)

**Zadanie:** Sprawdzić działanie wizytówki w przeglądarce.

**Kroki:**

1. Otwórz przeglądarkę na tej samej maszynie: `http://localhost` – powinna się załadować wizytówka.
2. Otwórz przeglądarkę z innego komputera w sieci: `http://<adres_IP_ubuntu>` – sprawdź, czy strona jest dostępna.
3. (Opcjonalnie) Zmodyfikuj `index.html` (np. zmień imię) i odśwież stronę – sprawdź, czy zmiany są widoczne.

***

## 3. Podsumowanie i zadanie domowe (10 min)

### Co powinni wiedzieć po lekcji

- Jak zainstalować Apache2 w Ubuntu.
- Gdzie znajdują się pliki konfiguracyjne i katalog dokumentów.
- Jak wdrożyć prostą stronę HTML/CSS na serwerze.
- Jak przetestować dostępność strony lokalnie i z sieci.


### Wskazówki dla nauczyciela

- Przygotuj wersję „gotową” wizytówki (pliki `index.html` i `style.css`) na pendrive lub w sieci szkolnej – uczniowie mogą ją skopiować, jeśli nie zdążą napisać od zera.
- Dla zaawansowanych: dodaj zadanie z konfiguracją VirtualHost (np. `wizytowka.local`) i edycją pliku `hosts` na Windows.

[^1]: https://miroslawzelent.pl/kurs-linux/instalacja-apache-ubuntu-php-mysql-phpmyadmin/

[^2]: https://iqhost.pl/blog/jak-zainstalowac-linux-apache-mysql-php-lamp-stack-na-ubuntu-20-04

[^3]: https://alexhost.com/pl/faq/co-to-jest-apache-i-do-czego-sluzy-przy-tworzeniu-stron-internetowych/

[^4]: https://soisk.info/index.php/Linux_Ubuntu_-_Instalacja_i_konfiguracja_serwera_Apache2

[^5]: https://piotrgabriel.pl/wiki/instalacja-serwera-www-na-ubuntu-20-4/

[^6]: https://creativecoding.pl/jak-zrobic-wizytowke-w-html-2/

[^7]: https://kurshtmlcss.pl/strona-html-css/jak-zrobic-strone-w-html-i-css-od-podstaw/

[^8]: https://plociennik.info/index.php/informatyka/systemy-operacyjne/linux/konfiguracja-serwera-http-na-przykladzie-apache

[^9]: https://hostovita.pl/blog/konfiguracja-virtualhost-apache-w-ubuntu-18/

[^10]: https://kurshtmlcss.pl/strona-html-css/szablon-strony/

[^11]: https://www.youtube.com/watch?v=GciQylkaNV0

[^12]: https://zse.rzeszow.pl/ubuntu/lekcja09-serwer-apache

[^13]: https://www.kurshtml.edu.pl/html/przyklady.html

[^14]: https://mlodyinformatyk.pl/lessons/lesson/58

[^15]: https://www.lscdn.pl/download/1/32938/JBudzynskascenariusz.pdf

[^16]: https://ckziumragowo.pl/szkolne-artykuly/2020/Instalacja-serwera-Apache-w-systemie-Ubuntu

[^17]: https://www.reddit.com/r/Ubuntu/comments/11l4ahq/how_can_i_create_a_simple_html_static_page_server/

[^18]: https://pl.vizitka.com/pl/wizytowki/templates?categoryId=5745

[^19]: https://www.youtube.com/watch?v=i4-hXmd2QSQ

[^20]: https://www.youtube.com/watch?v=-Uv8vn14MAI

[^21]: https://creativecoding.pl/jak-zrobic-wizytowke-w-html/

[^22]: https://ping.pl/blog/posts/jak-postawic-strone-na-ubuntu-i-apache/

[^23]: https://cyberfolks.pl/blog/strona-internetowa-wizytowka/

[^24]: https://sp3olkusz.pl/data/files/kodrdowyprzykadowejstronyhtml.pdf

[^25]: https://www.youtube.com/watch?v=LSWQG-FbqIw

[^26]: https://github.com/UlaWilk/WilczaChata

[^27]: https://cyberfolks.pl/blog/prosta-strona-internetowa/

[^28]: https://nicepage.com/pl/s/1393817/wizytowka-wzorcowa-szablon-css

[^29]: https://www.kurshtml.edu.pl/rss/?a=items\&id=1\&c=1

[^30]: https://ux.marszalkowski.org/bezplatny-responsorywny-szablon-strony-www/

[^31]: https://www.youtube.com/watch?v=dfzsVxFr_TU

[^32]: https://www.youtube.com/watch?v=EGoeKB2OjoE

[^33]: https://nicepage.com/pl/k/edukacja-szablony-css

[^34]: https://how2html.pl/moja-pierwsza-strona-internetowa/

[^35]: https://www.youtube.com/watch?v=K0gQ0swE64o

[^36]: https://studiokreacja.pl/blog/jezyk-do-tworzenia-stron-www-przewodnik-dla-profesjonalistow/

