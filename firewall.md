# Lekcja: Wprowadzenie do firewalla w Ubuntu i Oracle Linux (UFW i firewalld)


## 1. Cele lekcji

- **co** to jest firewall i po co się go używa.
- różnica między ruchem przychodzącym i wychodzącym.
- włączyć i skonfigurować UFW w Ubuntu (podstawowe reguły).
- sprawdzić stan firewalld w Oracle Linux i dodać prostą regułę.
- odczytać i zinterpretować podstawowe reguły zapory.

***

### 4.1. Wprowadzenie teoretyczne (15 min)

> „Firewall (zapora sieciowa) to strażnik na granicy komputera lub sieci. Sprawdza każdy pakiet danych i na podstawie **reguł** decyduje: przepuścić czy zablokować.”

- Firewall – filtr pakietów, reguły ALLOW / DENY.
- Ruch przychodzący (incoming) – z sieci do nas.
- Ruch wychodzący (outgoing) – od nas do sieci.
- Przykład reguły:
    - „Zezwól na ruch przychodzący na porcie 22/TCP (SSH) z dowolnego adresu.”[^6][^5]

Pytanie 

- Co się stanie, jeśli zablokujemy port 80 na serwerze WWW?
- Dlaczego nie powinniśmy zostawiać otwartych nieużywanych portów?

***

### 4.2. UFW w Ubuntu 

Cel: jak włączyć i skonfigurować UFW.

1. Sprawdzenie, czy UFW jest zainstalowany:
```bash
sudo ufw status
```

- Jeśli komunikat „Status: inactive” – dobrze, będziemy włączać.
- Jeśli nie ma komendy, instalacja (Ubuntu):

```bash
sudo apt update
sudo apt install ufw
```

2. Ustawienie domyślnych polityk:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Wyjaśnienie:

- `deny incoming` – domyślnie wszystko przychodzące jest blokowane.
- `allow outgoing` – wszystko wychodzące jest dozwolone (np. przeglądarka, apt).

3. Zezwolenie na SSH (żeby nie odciąć sobie dostępu zdalnego):
```bash
sudo ufw allow 22/tcp
```

lub (wydanie przyjazne):

```bash
sudo ufw allow OpenSSH
```

4. Włączenie zapory:
```bash
sudo ufw enable
```

- Pojawi się ostrzeżenie o możliwej utracie połączenia SSH – potwierdzamy `y`.

5. Sprawdzenie statusu (pełny):
```bash
sudo ufw status verbose
```

Omówienie:

- Status: active – zapora działa.
- Wypisane reguły, np. `22/tcp ALLOW Anywhere`.

6. Dodanie typowych usług HTTP/HTTPS:
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

7. Reguła z adresem IP (przykład):
```bash
sudo ufw allow from 192.168.1.100 to any port 5432 proto tcp
```

Wyjaśnienie:

- Tylko host 192.168.1.100 może łączyć się z naszym portem 5432 (np. PostgreSQL).[^10]

- Pokazanie ponumerowanych reguł 
```bash
sudo ufw status numbered
```

***

### 4.3. Ćwiczenia praktyczne z UFW (25 min)

#### Zadanie 1 – podstawowa konfiguracja

Zadanie:

1. Sprawdź status UFW:
```bash
sudo ufw status
```

2. Ustaw domyślne polityki:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

3. Dodaj reguły:
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

4. Włącz UFW:
```bash
sudo ufw enable
```

5. Sprawdź status:
```bash
sudo ufw status verbose
```

Wynik reguły dla portów 22, 80, 443.

#### Zadanie 2 – reguła z IP + usuwanie

Polecenie:

1. Dodaj regułę: zezwól tylko komputerowi 10.0.0.5 na dostęp do portu 5432/TCP:
```bash
sudo ufw allow from 10.0.0.5 to any port 5432 proto tcp
```

2. Wyświetl reguły z numerami:
```bash
sudo ufw status numbered
```

3. Usuń przed chwilą dodaną regułę, używając numeru, np.:
```bash
sudo ufw delete 4
```

4. Sprawdź ponownie status i potwierdź, że reguły już nie ma.

Jeśli czas pozwala – dodatkowe mini‑zadanie:

- Zablokuj port 21/TCP (FTP):

```bash
sudo ufw deny 21/tcp
```


***

### 4.4. firewalld w Oracle Linux – pokaz (15 min)

Cel: pokazać drugi firewall na innym systemie – Oracle Linux.

Na serwerze / VM nauczyciela (Oracle Linux 8/9):

1. Sprawdzenie statusu firewalld:
```bash
sudo systemctl status firewalld
```

Jeśli nieaktywny, uruchom i włącz na stałe:

```bash
sudo systemctl enable --now firewalld
```

2. Sprawdzenie aktualnego stanu zapory:
```bash
sudo firewall-cmd --state
```

3. Wyświetlenie wszystkich stref:
```bash
sudo firewall-cmd --list-all-zones
```

Wyjaśnienei:

- Strefy (zones) to zbiory reguł dla różnych poziomów zaufania: `public`, `home`, `work`, `trusted` itd.
- Najczęściej używana jest strefa `public` dla serwera dostępnego z internetu.

4. Wyświetlenie reguł w aktywnej strefie (zwykle `public`):
```bash
sudo firewall-cmd --zone=public --list-all
```

Pokazane będą m.in.:

- `services` – nazwy usług (np. ssh, http)
- `ports` – porty dodane ręcznie

5. Dodanie portów 22 i 1521 (przykład: SSH + Oracle DB) **na stałe**:
```bash
sudo firewall-cmd --permanent --zone=public --add-port=22/tcp
sudo firewall-cmd --permanent --zone=public --add-port=1521/tcp
```

6. Przeładowanie konfiguracji:
```bash
sudo firewall-cmd --reload
```

7. Ponowne sprawdzenie:
```bash
sudo firewall-cmd --zone=public --list-ports
```

Podkreśl różnicę:

- Ubuntu – prosty UFW, komendy `ufw allow`, `ufw deny`.
- Oracle Linux – firewalld, strefy i `firewall-cmd`, rozróżnienie konfiguracji „runtime” i „permanent”.

***

### 4.5. Podsumowanie i zadanie domowe (10 min)

krótkie podsumowanie:

- Firewall = filtr pakietów bazujący na regułach (port, IP, protokół).
- W Ubuntu: UFW – prosty interfejs do iptables / netfilter.
- W Oracle Linux: firewalld – zapora oparta o strefy i usługi.

Pytania kontrolne :

- Jaką domyślną politykę ustawiliśmy dla incoming w UFW? (deny).
- Jaką komendą sprawdzimy reguły UFW z numerami? (`sudo ufw status numbered`)
- Jak dodać port 1521/TCP w strefie public w firewalld na stałe? (`firewall-cmd --permanent --zone=public --add-port=1521/tcp`)


#### Propozycja zadania domowego

- Na swoim Ubuntu (lub VM) przygotuj skrypt bash, który:
    - włącza UFW,
    - ustawia `deny incoming`, `allow outgoing`,
    - dodaje reguły dla 22, 80, 443,
    - dodaje regułę zezwalającą tylko 1 wybranemu IP na dostęp do portu 5432.
- Skrypt ma zakończyć się wypisaniem `ufw status`.

***


