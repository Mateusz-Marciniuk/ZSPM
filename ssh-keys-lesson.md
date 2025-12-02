# Generowanie Kluczy i Uwierzytelnianie SSH
## Lekcja na 90 minut dla technikum - Projektowanie i Administracja Bazami Danych

---

## I. WSTĘP I CELE LEKCJI (5 minut)

### Motywacja
Dlaczego uwierzytelnianie kluczem jest lepsze od hasła?
- **Bezpieczeństwo** - klucz ma tysiące bitów vs kilkanaście znaków hasła
- **Odporność na brute-force** - praktycznie niemożliwe do złamania
- **Automatyzacja** - skrypty mogą łączyć się bez interakcji
- **Wygoda** - jeden klucz do wielu serwerów

---

## II. TEORIA - KRYPTOGRAFIA ASYMETRYCZNA (10 minut)

### A. Jak Działa Kryptografia Asymetryczna?

**Zasada:** Dwa matematycznie powiązane klucze:
- **Klucz prywatny** (private key) - tajny, nigdy nie opuszcza Twojego komputera
- **Klucz publiczny** (public key) - można go bezpiecznie udostępniać

**Analogia:**
- Klucz publiczny = otwarta skrzynka na listy (każdy może wrzucić)
- Klucz prywatny = klucz do skrzynki (tylko Ty możesz otworzyć)

### B. Proces Uwierzytelniania SSH

```
┌─────────────────┐                    ┌─────────────────┐
│     KLIENT      │                    │     SERWER      │
│                 │                    │                 │
│  Klucz prywatny │                    │  Klucz publiczny│
│  (~/.ssh/id_*)  │                    │  (authorized_   │
│                 │                    │      keys)      │
└────────┬────────┘                    └────────┬────────┘
         │                                      │
         │  1. Żądanie połączenia SSH           │
         │ ─────────────────────────────────────>
         │                                      │
         │  2. Serwer wysyła wyzwanie           │
         │     (losowy ciąg zaszyfrowany        │
         │      kluczem publicznym)             │
         │ <─────────────────────────────────────
         │                                      │
         │  3. Klient odszyfrowuje wyzwanie     │
         │     kluczem prywatnym i odsyła       │
         │ ─────────────────────────────────────>
         │                                      │
         │  4. Serwer weryfikuje odpowiedź      │
         │     → Jeśli OK = dostęp przyznany    │
         │ <─────────────────────────────────────
         │                                      │
```

### C. Algorytmy Kluczy SSH

| Algorytm | Długość klucza | Bezpieczeństwo | Rekomendacja |
|----------|----------------|----------------|--------------|
| RSA | 2048-4096 bitów | Dobre (4096) | Uniwersalny, starszy |
| Ed25519 | 256 bitów | Bardzo dobre | **ZALECANY** - szybszy, bezpieczniejszy |
| ECDSA | 256-521 bitów | Dobre | Alternatywa |
| DSA | 1024 bity | Słabe | **NIE UŻYWAĆ** - przestarzały |

**Dlaczego Ed25519?**
- Szybsze generowanie i weryfikacja
- Krótszy klucz przy równym bezpieczeństwie
- Odporny na timing attacks
- Nowoczesny standard (od OpenSSH 6.5)

---

## III. PRZYGOTOWANIE ŚRODOWISKA UBUNTU 24.04 (10 minut)

### A. Aktualizacja Systemu

```bash
# Aktualizacja listy pakietów
sudo apt update

# Aktualizacja zainstalowanych pakietów
sudo apt upgrade -y
```

### B. Instalacja Serwera SSH (jeśli nie jest zainstalowany)

```bash
# Sprawdzenie czy SSH jest zainstalowany
ssh -V

# Instalacja serwera OpenSSH
sudo apt install openssh-server -y

# Sprawdzenie statusu usługi
sudo systemctl status ssh

# Uruchomienie usługi (jeśli nie działa)
sudo systemctl start ssh

# Włączenie autostartu
sudo systemctl enable ssh
```

### C. Sprawdzenie Konfiguracji Sieci

```bash
# Sprawdzenie adresu IP serwera
ip addr show
# lub
hostname -I

# Sprawdzenie czy port 22 nasłuchuje
sudo ss -tlnp | grep 22
```

### D. Tworzenie Użytkownika Testowego (opcjonalnie)

```bash
# Na serwerze - tworzenie użytkownika do testów
sudo adduser student
sudo usermod -aG sudo student
```

### E. Struktura Katalogów SSH

```bash
# Katalog konfiguracji SSH użytkownika
~/.ssh/
├── authorized_keys    # Klucze publiczne autoryzowane do logowania
├── config             # Konfiguracja klienta SSH
├── id_ed25519         # Klucz prywatny Ed25519
├── id_ed25519.pub     # Klucz publiczny Ed25519
├── id_rsa             # Klucz prywatny RSA (jeśli używamy)
├── id_rsa.pub         # Klucz publiczny RSA
└── known_hosts        # Lista znanych hostów

# Uprawnienia (KRYTYCZNE!)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 644 ~/.ssh/config
```

---

## IV. GENEROWANIE KLUCZY SSH (15 minut)

### A. Generowanie Klucza Ed25519 (ZALECANE)

```bash
# Podstawowe polecenie
ssh-keygen -t ed25519 -C "komentarz@email.com"

# Pełna składnia z wszystkimi opcjami
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_serwer1 -C "student@technikum" -a 100
```

**Objaśnienie parametrów:**

| Parametr | Znaczenie |
|----------|-----------|
| `-t ed25519` | Typ algorytmu (ed25519) |
| `-f <ścieżka>` | Plik, w którym zapisać klucz |
| `-C "komentarz"` | Komentarz identyfikujący klucz |
| `-a 100` | Liczba rund KDF (zwiększa bezpieczeństwo passphrase) |
| `-N "passphrase"` | Hasło do klucza (lub puste "") |

**Przykład sesji:**

```bash
student@klient:~$ ssh-keygen -t ed25519 -C "student@technikum.pl"
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/student/.ssh/id_ed25519): [ENTER]
Enter passphrase (empty for no passphrase): [wpisz hasło]
Enter same passphrase again: [powtórz hasło]
Your identification has been saved in /home/student/.ssh/id_ed25519
Your public key has been saved in /home/student/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:qxCxjp6thlj59cjQKy+qTrPnlTNfCq/RKNP+bYCwyA8 student@technikum.pl
The key's randomart image is:
+--[ED25519 256]--+
|     .o.o        |
|     ..= .       |
|      + =        |
|     . B o       |
|    . X S        |
|   . * X .       |
|    = O.+ o      |
|   ..*.=o=.o     |
|    oE++==+.     |
+----[SHA256]-----+
```

### B. Generowanie Klucza RSA (alternatywa)

```bash
# RSA 4096-bitowy (zalecany rozmiar)
ssh-keygen -t rsa -b 4096 -C "student@technikum.pl"
```

**Przykład sesji:**

```bash
student@klient:~$ ssh-keygen -t rsa -b 4096 -C "student@technikum.pl"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/student/.ssh/id_rsa): [ENTER]
Enter passphrase (empty for no passphrase): [wpisz hasło]
Enter same passphrase again: [powtórz hasło]
Your identification has been saved in /home/student/.ssh/id_rsa
Your public key has been saved in /home/student/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:abc123...xyz789 student@technikum.pl
```

### C. Porównanie Wygenerowanych Kluczy

```bash
# Wyświetlenie klucza publicznego Ed25519 (krótki!)
cat ~/.ssh/id_ed25519.pub
# Wynik: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq... student@technikum.pl

# Wyświetlenie klucza publicznego RSA (długi)
cat ~/.ssh/id_rsa.pub
# Wynik: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... student@technikum.pl

# Sprawdzenie fingerprinta klucza
ssh-keygen -lf ~/.ssh/id_ed25519.pub
# Wynik: 256 SHA256:qxCxjp6thlj59cjQKy+qTrPnlTNfCq/RKNP+bYCwyA8 student@technikum.pl (ED25519)
```

### D. Bezpieczeństwo Passphrase

**Passphrase to hasło chroniące klucz prywatny:**
- Nawet jeśli ktoś ukradnie plik klucza, bez passphrase go nie użyje
- **ZAWSZE** ustawiaj passphrase dla kluczy produkcyjnych
- Użyj silnego hasła: min. 12 znaków, mieszane

**Zmiana passphrase istniejącego klucza:**

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519
# Zostaniesz poproszony o stare i nowe hasło
```

---

## V. KOPIOWANIE KLUCZA NA SERWER (10 minut)

### A. Metoda 1: ssh-copy-id (ZALECANA)

```bash
# Składnia
ssh-copy-id -i ~/.ssh/id_ed25519.pub użytkownik@adres_serwera

# Przykład
ssh-copy-id -i ~/.ssh/id_ed25519.pub student@192.168.1.100

# Jeśli serwer używa niestandardowego portu
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 student@192.168.1.100
```

**Przykład sesji:**

```bash
student@klient:~$ ssh-copy-id -i ~/.ssh/id_ed25519.pub student@192.168.1.100
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/student/.ssh/id_ed25519.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
student@192.168.1.100's password: [wpisz hasło użytkownika na serwerze]

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'student@192.168.1.100'"
and check to make sure that only the key(s) you wanted were added.
```

### B. Metoda 2: Ręczne Kopiowanie

Jeśli `ssh-copy-id` nie jest dostępne:

```bash
# Krok 1: Wyświetl klucz publiczny
cat ~/.ssh/id_ed25519.pub

# Krok 2: Skopiuj wyświetlony tekst

# Krok 3: Na serwerze - zaloguj się hasłem
ssh student@192.168.1.100

# Krok 4: Utwórz katalog .ssh (jeśli nie istnieje)
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Krok 5: Dodaj klucz do authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq... student@technikum.pl" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

**Alternatywa - jednolinijkowe polecenie:**

```bash
cat ~/.ssh/id_ed25519.pub | ssh student@192.168.1.100 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### C. Weryfikacja Logowania Kluczem

```bash
# Próba logowania (powinno zapytać o passphrase, nie hasło!)
ssh student@192.168.1.100

# Verbose mode - szczegóły procesu uwierzytelniania
ssh -v student@192.168.1.100

# Bardzo szczegółowy tryb debugowania
ssh -vvv student@192.168.1.100
```

**Prawidłowy wynik w trybie verbose:**

```
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Offering public key: /home/student/.ssh/id_ed25519 ED25519 SHA256:qxCxjp6...
debug1: Server accepts key: /home/student/.ssh/id_ed25519 ED25519 SHA256:qxCxjp6...
debug1: Authentication succeeded (publickey).
```

---

## VI. ZARZĄDZANIE KLUCZAMI - SSH-AGENT (10 minut)

### A. Co to jest SSH-Agent?

**SSH-Agent** to program przechowujący odszyfrowane klucze prywatne w pamięci:
- Wpisujesz passphrase raz na sesję
- Agent automatycznie podaje klucz przy każdym połączeniu
- Bezpieczniejsze niż klucz bez hasła

### B. Uruchamianie SSH-Agent

```bash
# Sprawdzenie czy agent działa
echo $SSH_AUTH_SOCK

# Uruchomienie agenta (jeśli nie działa)
eval "$(ssh-agent -s)"
# Wynik: Agent pid 12345

# W Ubuntu 24.04 agent zwykle uruchamia się automatycznie
```

### C. Dodawanie Kluczy do Agenta

```bash
# Dodanie domyślnego klucza
ssh-add

# Dodanie konkretnego klucza
ssh-add ~/.ssh/id_ed25519

# Dodanie z limitem czasu (np. 1 godzina)
ssh-add -t 3600 ~/.ssh/id_ed25519

# Wylistowanie kluczy w agencie
ssh-add -l

# Usunięcie wszystkich kluczy z agenta
ssh-add -D
```

**Przykład sesji:**

```bash
student@klient:~$ ssh-add ~/.ssh/id_ed25519
Enter passphrase for /home/student/.ssh/id_ed25519: [wpisz passphrase]
Identity added: /home/student/.ssh/id_ed25519 (student@technikum.pl)

student@klient:~$ ssh-add -l
256 SHA256:qxCxjp6thlj59cjQKy+qTrPnlTNfCq/RKNP+bYCwyA8 student@technikum.pl (ED25519)
```

### D. Automatyczne Dodawanie Klucza (Ubuntu)

Dodaj do `~/.ssh/config`:

```
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes
```

To automatycznie doda klucz do agenta przy pierwszym użyciu.

---

## VII. PLIK KONFIGURACYJNY SSH (~/.ssh/config) (10 minut)

### A. Tworzenie Pliku Konfiguracyjnego

```bash
# Utwórz/edytuj plik config
nano ~/.ssh/config

# Ustaw odpowiednie uprawnienia
chmod 600 ~/.ssh/config
```

### B. Struktura Pliku Config

```bash
# ~/.ssh/config

# Ustawienia globalne (dla wszystkich hostów)
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Serwer bazy danych - produkcja
Host db-prod
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_ed25519_prod

# Serwer bazy danych - development
Host db-dev
    HostName 192.168.1.101
    User developer
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_dev

# Serwer www
Host www
    HostName www.firma.pl
    User webmaster
    IdentityFile ~/.ssh/id_ed25519

# Serwer za bastion host (jump host)
Host internal-db
    HostName 10.0.0.50
    User dbadmin
    ProxyJump bastion

Host bastion
    HostName bastion.firma.pl
    User jumpuser
    IdentityFile ~/.ssh/id_ed25519_bastion
```

### C. Użycie Aliasów

Po skonfigurowaniu, zamiast:
```bash
ssh -i ~/.ssh/id_ed25519_prod -p 22 admin@192.168.1.100
```

Wystarczy:
```bash
ssh db-prod
```

### D. Ważne Opcje Konfiguracyjne

| Opcja | Opis | Przykład |
|-------|------|----------|
| `Host` | Alias hosta | `Host serwer1` |
| `HostName` | Rzeczywisty adres/IP | `HostName 192.168.1.100` |
| `User` | Nazwa użytkownika | `User admin` |
| `Port` | Port SSH | `Port 2222` |
| `IdentityFile` | Ścieżka do klucza | `IdentityFile ~/.ssh/id_ed25519` |
| `IdentitiesOnly` | Użyj tylko podanego klucza | `IdentitiesOnly yes` |
| `ProxyJump` | Host pośredni (bastion) | `ProxyJump bastion` |
| `ServerAliveInterval` | Keepalive co X sekund | `ServerAliveInterval 60` |
| `ForwardAgent` | Przekazywanie agenta | `ForwardAgent yes` |

---

## VIII. ZABEZPIECZANIE SERWERA SSH - HARDENING (10 minut)

### A. Kopia Zapasowa Konfiguracji

```bash
# ZAWSZE przed zmianami - backup!
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
```

### B. Edycja Konfiguracji Serwera

```bash
sudo nano /etc/ssh/sshd_config
```

### C. Zalecane Ustawienia Bezpieczeństwa

```bash
# /etc/ssh/sshd_config

# Port - zmiana z domyślnego (opcjonalnie)
Port 22
# Port 2222  # alternatywa - zmniejsza ataki automatyczne

# Protokół - tylko SSH2
Protocol 2

# Nasłuchiwanie - tylko IPv4 lub konkretny IP
#AddressFamily inet
#ListenAddress 192.168.1.100

# Logowanie root - WYŁĄCZONE
PermitRootLogin no

# Uwierzytelnianie kluczem - WŁĄCZONE
PubkeyAuthentication yes

# Ścieżka do authorized_keys
AuthorizedKeysFile .ssh/authorized_keys

# Uwierzytelnianie hasłem - WYŁĄCZONE (po skonfigurowaniu kluczy!)
PasswordAuthentication no

# Puste hasła - WYŁĄCZONE
PermitEmptyPasswords no

# Challenge-response - WYŁĄCZONE
KbdInteractiveAuthentication no

# Przekazywanie X11 - WYŁĄCZONE (jeśli niepotrzebne)
X11Forwarding no

# Czas na logowanie (grace time)
LoginGraceTime 30

# Maksymalna liczba prób
MaxAuthTries 3

# Maksymalna liczba sesji
MaxSessions 3

# Banner ostrzegawczy (opcjonalnie)
Banner /etc/ssh/banner.txt

# Algorytmy szyfrowania (nowoczesne)
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
```

### D. Uwaga: Plik Cloud-Init (Ubuntu 24.04)

```bash
# Ubuntu 24.04 może mieć nadpisującą konfigurację:
cat /etc/ssh/sshd_config.d/50-cloud-init.conf

# Jeśli zawiera "PasswordAuthentication yes", usuń lub zmień:
sudo rm /etc/ssh/sshd_config.d/50-cloud-init.conf
# lub
sudo nano /etc/ssh/sshd_config.d/50-cloud-init.conf
# zmień na: PasswordAuthentication no
```

### E. Weryfikacja i Restart

```bash
# Test konfiguracji (WAŻNE - przed restartem!)
sudo sshd -t

# Jeśli brak błędów - restart usługi
sudo systemctl restart ssh

# Sprawdzenie statusu
sudo systemctl status ssh

# WAŻNE: Nie zamykaj bieżącej sesji!
# Otwórz NOWY terminal i przetestuj logowanie
ssh student@192.168.1.100
```

### F. Tworzenie Bannera (opcjonalnie)

```bash
sudo nano /etc/ssh/banner.txt
```

Zawartość:
```
**********************************************
*                                            *
*   UWAGA! Dostęp tylko dla autoryzowanych   *
*   użytkowników. Wszystkie działania są     *
*   monitorowane i logowane.                 *
*                                            *
**********************************************
```

---

## IX. PRAKTYCZNE ĆWICZENIA (15 minut)

### Ćwiczenie 1: Generowanie i Konfiguracja Klucza

**Zadanie:** Wygeneruj klucz Ed25519, skopiuj na serwer i zaloguj się.

**Kroki:**

```bash
# 1. Wygeneruj klucz Ed25519
ssh-keygen -t ed25519 -C "twoj_email@example.com"

# 2. Sprawdź wygenerowane pliki
ls -la ~/.ssh/

# 3. Wyświetl klucz publiczny
cat ~/.ssh/id_ed25519.pub

# 4. Skopiuj klucz na serwer
ssh-copy-id student@localhost  # lub adres serwera

# 5. Zaloguj się bez hasła (tylko passphrase)
ssh student@localhost

# 6. Sprawdź zawartość authorized_keys na serwerze
cat ~/.ssh/authorized_keys
```

### Ćwiczenie 2: Konfiguracja SSH-Agent

**Zadanie:** Skonfiguruj ssh-agent aby nie pytał o passphrase przy każdym połączeniu.

**Kroki:**

```bash
# 1. Sprawdź czy agent działa
echo $SSH_AUTH_SOCK

# 2. Dodaj klucz do agenta
ssh-add ~/.ssh/id_ed25519

# 3. Sprawdź dodane klucze
ssh-add -l

# 4. Przetestuj logowanie (nie powinno pytać o passphrase)
ssh student@localhost
ssh student@localhost  # drugie połączenie - też bez pytania
```

### Ćwiczenie 3: Plik Config

**Zadanie:** Utwórz plik config z aliasami dla dwóch serwerów.

**Kroki:**

```bash
# 1. Utwórz plik config
nano ~/.ssh/config

# 2. Dodaj zawartość:
Host local-server
    HostName localhost
    User student
    IdentityFile ~/.ssh/id_ed25519

Host test-server
    HostName 127.0.0.1
    User student
    Port 22
    IdentityFile ~/.ssh/id_ed25519

# 3. Zapisz i ustaw uprawnienia
chmod 600 ~/.ssh/config

# 4. Przetestuj aliasy
ssh local-server
ssh test-server
```

### Ćwiczenie 4: Hardening Serwera

**Zadanie:** Wyłącz logowanie hasłem i zezwól tylko na klucze.

**Kroki:**

```bash
# 1. Backup konfiguracji
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 2. Edytuj konfigurację
sudo nano /etc/ssh/sshd_config

# 3. Znajdź i zmień:
#    PasswordAuthentication yes  →  PasswordAuthentication no
#    PermitRootLogin yes        →  PermitRootLogin no

# 4. Sprawdź składnię
sudo sshd -t

# 5. Restart SSH (NIE zamykaj obecnej sesji!)
sudo systemctl restart ssh

# 6. W NOWYM terminalu przetestuj logowanie
ssh student@localhost

# 7. Spróbuj zalogować się hasłem (powinno się nie udać)
ssh -o PreferredAuthentications=password student@localhost
# Wynik: Permission denied (publickey).
```

---

## X. ROZWIĄZYWANIE PROBLEMÓW (5 minut)

### A. Najczęstsze Błędy

**Problem 1: Permission denied (publickey)**

```bash
# Sprawdź uprawnienia na serwerze
ls -la ~/.ssh/
# Powinno być:
# drwx------ .ssh
# -rw------- authorized_keys

# Napraw uprawnienia
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**Problem 2: Klucz nie jest akceptowany**

```bash
# Sprawdź verbose log
ssh -vvv user@server

# Upewnij się, że klucz jest w authorized_keys
cat ~/.ssh/authorized_keys

# Sprawdź czy klucz publiczny jest kompletny (bez złamania linii)
```

**Problem 3: Agent nie pamięta klucza**

```bash
# Sprawdź czy agent działa
echo $SSH_AUTH_SOCK

# Uruchom agenta
eval "$(ssh-agent -s)"

# Dodaj klucz
ssh-add ~/.ssh/id_ed25519
```

**Problem 4: Zablokowany dostęp po zmianie konfiguracji**

```bash
# Użyj konsoli fizycznej/VNC do serwera
# Przywróć backup konfiguracji
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### B. Przydatne Komendy Diagnostyczne

```bash
# Szczegółowy log połączenia
ssh -vvv user@server

# Sprawdzenie konfiguracji serwera
sudo sshd -T

# Logi systemowe SSH
sudo journalctl -u ssh -f

# Test konkretnego klucza
ssh -i ~/.ssh/konkretny_klucz user@server

# Sprawdzenie fingerprinta klucza serwera
ssh-keyscan -t ed25519 server_address
```

---

## XI. PODSUMOWANIE I BEST PRACTICES (5 minut)

### Kluczowe Punkty Lekcji

1. **Używaj Ed25519** - szybszy i bezpieczniejszy niż RSA
2. **Zawsze ustawiaj passphrase** - chroni klucz prywatny
3. **Używaj ssh-agent** - wygoda bez utraty bezpieczeństwa
4. **Wyłącz logowanie hasłem** - po skonfigurowaniu kluczy
5. **Zabezpiecz uprawnienia** - 700 dla .ssh, 600 dla plików
6. **Testuj przed zamknięciem sesji** - unikaj blokady dostępu

### Best Practices

| Praktyka | Dlaczego |
|----------|----------|
| Osobne klucze dla różnych celów | Łatwiejsze zarządzanie i revokacja |
| Rotacja kluczy co 12 miesięcy | Minimalizacja ryzyka kompromitacji |
| Backup kluczy prywatnych | Offline, zaszyfrowany (np. USB w sejfie) |
| Komentarze w kluczach | Identyfikacja - kto, kiedy, do czego |
| Monitorowanie logów SSH | Wykrywanie prób włamań |
| Fail2Ban | Automatyczna blokada po nieudanych próbach |

### Checklist Bezpieczeństwa

- [ ] Klucz Ed25519 z passphrase
- [ ] Klucz skopiowany bezpiecznie na serwer
- [ ] Logowanie kluczem działa
- [ ] PasswordAuthentication = no
- [ ] PermitRootLogin = no
- [ ] Uprawnienia .ssh i plików poprawne
- [ ] SSH-Agent skonfigurowany
- [ ] Plik ~/.ssh/config dla wygody

---

## XII. DODATKOWE ZASOBY

### Przydatne Polecenia - Ściągawka

```bash
# Generowanie kluczy
ssh-keygen -t ed25519 -C "komentarz"
ssh-keygen -t rsa -b 4096 -C "komentarz"

# Zmiana passphrase
ssh-keygen -p -f ~/.ssh/klucz

# Fingerprint klucza
ssh-keygen -lf ~/.ssh/klucz.pub

# Kopiowanie klucza
ssh-copy-id -i ~/.ssh/klucz.pub user@server

# SSH-Agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/klucz
ssh-add -l
ssh-add -D

# Testowanie połączenia
ssh -v user@server
ssh -vvv user@server

# Restart serwera SSH
sudo systemctl restart ssh
sudo systemctl status ssh

# Test konfiguracji serwera
sudo sshd -t
sudo sshd -T
```

### Pytania Sprawdzające

1. Czym różni się klucz publiczny od prywatnego?
2. Dlaczego Ed25519 jest lepszy od RSA?
3. Co robi polecenie ssh-copy-id?
4. Po co używamy passphrase?
5. Jak działa ssh-agent?
6. Jakie uprawnienia powinien mieć plik authorized_keys?
7. Dlaczego wyłączamy PasswordAuthentication?
8. Co zrobić przed restartem serwera SSH po zmianach konfiguracji?

---

## Notatki dla Nauczyciela

### Przygotowanie Laboratorium
- 2 maszyny wirtualne Ubuntu 24.04 (lub jedna z localhost)
- Sieć wewnętrzna między VM
- Możliwość resetu VM w razie blokady

### Typowe Problemy Uczniów
- Złe uprawnienia plików (chmod)
- Niekompletny klucz w authorized_keys (złamanie linii)
- Zamknięcie sesji przed testem nowej konfiguracji
- Pomylenie klucza publicznego z prywatnym

### Rozszerzenia Tematu
- Certyfikaty SSH (SSH CA)
- Hardware keys (YubiKey)
- Fail2Ban - ochrona przed brute-force
- Port knocking
- Jump hosts / Bastion hosts

---

**Koniec lekcji. Czas na pytania i dyskusję!**