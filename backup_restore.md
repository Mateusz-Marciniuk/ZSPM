
# Lekcja: MySQL – backup i odzyskiwanie danych

**Czas trwania: 90 minut**  
**Zgodnie z programem nauczania PiABD-2025-2026 i wymaganiami egzaminu INF.03**

---

## Struktura lekcji (90 minut)
1. **Wprowadzenie do backup'ów bazy danych** (10 min)
2. **Backup z wykorzystaniem mysqldump** (30 min)
3. **Backup i restore przez phpMyAdmin** (20 min)
4. **Backup fizyczny i binarne logi** (15 min)
5. **Strategie backup i automatyzacja** (10 min)
6. **Praktyczne ćwiczenia i rozwiązywanie problemów** (5 min)

---

## Część 1: Wprowadzenie do backup'ów bazy danych (10 minut)

### Dlaczego backup jest kluczowy?
Backup bazy danych to proces tworzenia kopii zapasowych danych w celu:
- **Ochrony przed utratą danych** (awarie sprzętowe, błędy ludzkie)
- **Możliwości przywrócenia** konkretnego stanu bazy
- **Migracji danych** między serwerami
- **Spełnienia wymagań prawnych** dotyczących archiwizacji

### Rodzaje backup'ów w MySQL

| Typ backupu | Opis | Zastosowanie |
|-------------|------|--------------|
| **Logiczny** | Eksport struktury i danych do pliku SQL | mysqldump, phpMyAdmin |
| **Fizyczny** | Kopiowanie plików bazy danych | Szybkie backup dużych baz |
| **Przyrostowy** | Tylko zmiany od ostatniego backupu | Binary logs |
| **Pełny** | Kompletna kopia całej bazy | Codzienne backup'y |

### Przygotowanie środowiska testowego

```

-- Tworzymy bazę testową do ćwiczeń
CREATE DATABASE backup_test;
USE backup_test;

-- Tworzenie przykładowych tabel
CREATE TABLE klienci (
id INT PRIMARY KEY AUTO_INCREMENT,
imie VARCHAR(50),
nazwisko VARCHAR(50),
email VARCHAR(100),
data_rejestracji DATE
);

CREATE TABLE produkty (
id INT PRIMARY KEY AUTO_INCREMENT,
nazwa VARCHAR(200),
cena DECIMAL(10,2),
kategoria VARCHAR(50)
);

-- Wstawianie przykładowych danych
INSERT INTO klienci (imie, nazwisko, email, data_rejestracji) VALUES
('Jan', 'Kowalski', 'jan@test.com', '2024-01-15'),
('Anna', 'Nowak', 'anna@test.com', '2024-02-20'),
('Piotr', 'Wiśniewski', 'piotr@test.com', '2024-03-10');

INSERT INTO produkty (nazwa, cena, kategoria) VALUES
('Laptop', 2999.99, 'Elektronika'),
('Mysz', 49.99, 'Akcesoria'),
('Monitor', 899.99, 'Elektronika');

```

---

## Część 2: Backup z wykorzystaniem mysqldump (30 minut)

### Co to jest mysqldump?
**mysqldump** to narzędzie wiersza poleceń MySQL do tworzenia logicznych backup'ów. Generuje plik SQL zawierający wszystkie polecenia potrzebne do odtworzenia struktury i danych.

### Podstawowa składnia mysqldump

```

mysqldump [opcje] baza_danych > plik_backupu.sql

```

### Backup pojedynczej bazy danych

```


# Podstawowy backup bazy

mysqldump -u root -p backup_test > backup_test_dump.sql

# Backup z dodatkowymi opcjami

mysqldump -u root -p --single-transaction --routines --triggers backup_test > backup_test_full.sql

```

**Wyjaśnienie opcji:**
- `-u root` – nazwa użytkownika
- `-p` – zapytanie o hasło
- `--single-transaction` – spójność danych dla InnoDB
- `--routines` – backup procedur składowanych
- `--triggers` – backup triggerów

### Backup wszystkich baz danych

```


# Backup wszystkich baz

mysqldump -u root -p --all-databases > all_databases_backup.sql

# Backup z dodatkowymi informacjami

mysqldump -u root -p --all-databases --routines --events > complete_backup.sql

```

### Backup konkretnych tabel

```


# Backup pojedynczej tabeli

mysqldump -u root -p backup_test klienci > klienci_backup.sql

# Backup wielu wybranych tabel

mysqldump -u root -p backup_test klienci produkty > wybrane_tabele.sql

```

### Backup ze strukturą bez danych

```


# Tylko struktura (bez danych)

mysqldump -u root -p --no-data backup_test > struktura_backup.sql

# Tylko dane (bez struktury)

mysqldump -u root -p --no-create-info backup_test > dane_backup.sql

```

### Backup z kompresją

```


# Backup z kompresją gzip

mysqldump -u root -p backup_test | gzip > backup_test.sql.gz

# Backup z kompresją 7zip (Windows)

mysqldump -u root -p backup_test | 7z a -si backup_test.sql.7z

```

### Przywracanie z mysqldump

```


# Przywrócenie pojedynczej bazy

mysql -u root -p backup_test < backup_test_dump.sql

# Przywrócenie wszystkich baz

mysql -u root -p < all_databases_backup.sql

# Przywrócenie z dekompresją

gunzip < backup_test.sql.gz | mysql -u root -p backup_test

```

### Przykład kompletnego backup'u z datą

```


# Windows (CMD)

set TODAY=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
mysqldump -u root -p backup_test > backup_test_%TODAY%.sql

# Linux/Mac

TODAY=$(date +%Y-%m-%d)
mysqldump -u root -p backup_test > backup_test_$TODAY.sql

```

### Sprawdzenie zawartości pliku backup

```


# Wyświetlenie pierwszych linii backup'u

head -20 backup_test_dump.sql

# Wyszukanie konkretnej tabeli w backup'ie

grep "CREATE TABLE" backup_test_dump.sql

```

---

## Część 3: Backup i restore przez phpMyAdmin (20 minut)

### Backup przez phpMyAdmin

**KROK 1: Dostęp do phpMyAdmin**
```

http://localhost/phpmyadmin

```

**KROK 2: Wybór bazy do backup'u**
- Wybierz bazę `backup_test` z panelu lewego
- Kliknij zakładkę "Eksport" w górnym menu

**KROK 3: Konfiguracja eksportu**

#### Szybki eksport (domyślny)
- Format: SQL
- Kliknij "Wykonaj"
- Plik zostanie pobrany automatycznie

#### Niestandardowy eksport (zaawansowany)
```

Opcje eksportu:
☑ Struktura
☑ Dane
☑ Dodaj polecenie DROP TABLE
☑ Dodaj AUTO_INCREMENT
☑ Umieść nazwy kolumn w cudzysłowie

```

**KROK 4: Dodatkowe opcje**
- **Kompresja:** zip, gzip
- **Format nazwy pliku:** `@DATABASE@_@DATE@.sql`
- **Kodowanie znaków:** utf-8

### Restore przez phpMyAdmin

**KROK 1: Przygotowanie bazy docelowej**
```

-- Usuń starą bazę (jeśli istnieje)
DROP DATABASE IF EXISTS backup_test_restored;

-- Utwórz nową bazę
CREATE DATABASE backup_test_restored;

```

**KROK 2: Import danych**
- Wybierz bazę `backup_test_restored`
- Kliknij zakładkę "Import"
- Kliknij "Wybierz plik" i wskaż plik backup'u
- Ustaw kodowanie na "utf-8"
- Kliknij "Wykonaj"

**KROK 3: Weryfikacja importu**
```

-- Sprawdź tabele
SHOW TABLES FROM backup_test_restored;

-- Sprawdź dane
SELECT * FROM backup_test_restored.klienci;
SELECT COUNT(*) FROM backup_test_restored.produkty;

```

### Częste problemy z phpMyAdmin

#### Problem: Za duży plik backup'u
```

Rozwiązanie:

1. Zwiększ limity w php.ini:
upload_max_filesize = 100M
post_max_size = 100M
max_execution_time = 300
2. Lub użyj mysqldump dla dużych plików
```

#### Problem: Timeout przy imporcie
```

Rozwiązanie:

1. Podziel backup na mniejsze części
2. Zwiększ max_execution_time
3. Użyj line-by-line import
```

---

## Część 4: Backup fizyczny i binarne logi (15 minut)

### Backup fizyczny – kopiowanie plików

#### Lokalizacja plików MySQL (XAMPP)
```

Windows: C:\xampp\mysql\data\
Linux: /var/lib/mysql/

```

#### Procedura backup fizycznego
```


# 1. ZATRZYMAJ serwer MySQL!

# W XAMPP: zatrzymaj MySQL w panelu kontrolnym

# 2. Skopiuj folder bazy danych

# Windows

xcopy "C:\xampp\mysql\data\backup_test" "D:\MySQL_Backups\backup_test_physical" /E /I

# Linux

cp -R /var/lib/mysql/backup_test /backup/backup_test_physical

# 3. Uruchom ponownie serwer MySQL

```

**Zalety backup fizycznego:**
- Bardzo szybki dla dużych baz
- Zachowuje wszystkie pliki systemowe
- Idealny dla disaster recovery

**Wady backup fizycznego:**
- Wymaga zatrzymania serwera
- Nie przenośny między różnymi wersjami MySQL
- Większy rozmiar plików

### Binary logs – backup przyrostowy

#### Włączenie binary logs (w my.cnf)
```

[mysqld]
log-bin=mysql-bin
server-id=1

```

#### Sprawdzenie binary logs
```

-- Wyświetl aktywne binary logs
SHOW BINARY LOGS;

-- Sprawdź aktualny binary log
SHOW MASTER STATUS;

-- Wyświetl zawartość binary log
SHOW BINLOG EVENTS IN 'mysql-bin.000001';

```

#### Backup z binary logs
```


# Flush binary logs (rozpocznij nowy)

mysql -u root -p -e "FLUSH LOGS;"

# Backup binary logs

mysqlbinlog mysql-bin.000001 > binlog_backup.sql

# Przywrócenie z binary logs (point-in-time recovery)

mysqlbinlog mysql-bin.000001 --start-position=154 --stop-position=368 | mysql -u root -p

```

### Point-in-time recovery (PITR)

```


# Scenariusz: Przywrócenie bazy do stanu z 14:30

# 1. Przywróć ostatni pełny backup

mysql -u root -p backup_test < backup_test_morning.sql

# 2. Zastosuj binary logs do określonego czasu

mysqlbinlog --start-datetime="2024-03-15 08:00:00" --stop-datetime="2024-03-15 14:30:00" mysql-bin.000001 | mysql -u root -p backup_test

```

---

## Część 5: Strategie backup i automatyzacja (10 minut)

### Strategia 3-2-1 backup
- **3** kopie danych (oryginał + 2 backup'y)
- **2** różne nośniki (dysk lokalny + chmura)
- **1** backup poza siedzibą (offsite)

### Harmonogram backup'ów

#### Skrypt backup Windows (backup_script.bat)
```

@echo off
set TODAY=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set BACKUP_DIR=D:\MySQL_Backups
set MYSQL_USER=root
set MYSQL_PASS=haslo

echo Starting backup at %TIME%
cd "C:\xampp\mysql\bin"

mysqldump -u %MYSQL_USER% -p%MYSQL_PASS% --all-databases > %BACKUP_DIR%\full_backup_%TODAY%.sql

if %ERRORLEVEL% EQU 0 (
echo Backup completed successfully
7z a %BACKUP_DIR%\full_backup_%TODAY%.zip %BACKUP_DIR%\full_backup_%TODAY%.sql
del %BACKUP_DIR%\full_backup_%TODAY%.sql
) else (
echo Backup failed!
)

```

#### Skrypt backup Linux (backup_script.sh)
```

\#!/bin/bash
TODAY=\$(date +%Y-%m-%d)
BACKUP_DIR="/backup/mysql"
MYSQL_USER="root"
MYSQL_PASS="haslo"

echo "Starting backup at \$(date)"
mysqldump -u $MYSQL_USER -p$MYSQL_PASS --all-databases | gzip > $BACKUP_DIR/full_backup_$TODAY.sql.gz

if [ \$? -eq 0 ]; then
echo "Backup completed successfully"
\# Usuń backup starsze niż 7 dni
find \$BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
else
echo "Backup failed!"
exit 1
fi

```

### Automatyzacja backup'ów

#### Windows – Harmonogram zadań (Task Scheduler)
```

1. Otwórz Task Scheduler
2. Create Basic Task
3. Name: MySQL Daily Backup
4. Trigger: Daily at 2:00 AM
5. Action: Start Program
6. Program: D:\scripts\backup_script.bat
```

#### Linux – Crontab
```


# Edycja crontab

crontab -e

# Backup codziennie o 2:00

0 2 * * * /home/user/scripts/backup_script.sh >> /var/log/mysql_backup.log 2>\&1

# Backup co godzinę (binary logs)

0 * * * * mysqladmin flush-logs

```

### Monitoring i alerty backup
```


# Sprawdzenie czy backup się udał

if [ -f "/backup/mysql/full_backup_\$(date +%Y-%m-%d).sql.gz" ]; then
echo "Backup OK" | mail -s "MySQL Backup Success" admin@company.com
else
echo "Backup FAILED" | mail -s "MySQL Backup FAILURE" admin@company.com
fi

```

---

## Część 6: Praktyczne ćwiczenia i rozwiązywanie problemów (5 minut)

### Kompleksowe ćwiczenie backup/restore

```

-- 1. Stwórz bazę testową z danymi
CREATE DATABASE backup_exercise;
USE backup_exercise;

CREATE TABLE users (
id INT PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(50),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username) VALUES
('user1'), ('user2'), ('user3');

-- 2. Wykonaj backup

```

```


# mysqldump backup

mysqldump -u root -p backup_exercise > exercise_backup.sql

```

```

-- 3. Symuluj utratę danych
DROP DATABASE backup_exercise;

-- 4. Przywróć z backup'u

```

```


# Restore

mysql -u root -p -e "CREATE DATABASE backup_exercise;"
mysql -u root -p backup_exercise < exercise_backup.sql

```

```

-- 5. Weryfikuj przywrócenie
USE backup_exercise;
SELECT * FROM users;

```

### Rozwiązywanie typowych problemów

#### Problem: "Table doesn't exist" po restore
```

-- Sprawdź czy tabele zostały utworzone
SHOW TABLES;

-- Sprawdź logi błędów
SHOW WARNINGS;

-- Rozwiązanie: wykonaj restore ponownie z opcją --force

```

```

mysql -u root -p --force backup_exercise < exercise_backup.sql

```

#### Problem: Błędy kodowania znaków
```


# Backup z określonym kodowaniem

mysqldump -u root -p --default-character-set=utf8mb4 backup_exercise > backup_utf8.sql

# Restore z określonym kodowaniem

mysql -u root -p --default-character-set=utf8mb4 backup_exercise < backup_utf8.sql

```

#### Problem: Za mało miejsca na dysku podczas backup
```


# Backup bezpośrednio skompresowany

mysqldump -u root -p backup_exercise | gzip > backup_compressed.sql.gz

# Backup do określonej lokalizacji

mysqldump -u root -p backup_exercise > /tmp/backup_exercise.sql

```

### Najlepsze praktyki backup

1. **Testuj restore regularnie** – backup bez możliwości restore jest bezwartościowy
2. **Dokumentuj procedury** – każdy w zespole powinien umieć przywrócić dane
3. **Monitoruj rozmiar backup'ów** – gwałtowny wzrost może wskazywać problemy
4. **Szyfruj wrażliwe backup'y** – osobiste dane wymagają dodatkowej ochrony
5. **Przechowuj backup'y w różnych lokalizacjach** – zabezpieczenie przed katastrofami

### Przydatne polecenia diagnostyczne

```


# Sprawdź rozmiar bazy danych

mysql -u root -p -e "SELECT table_schema 'Database Name', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'DB Size in MB' FROM information_schema.tables GROUP BY table_schema;"

# Sprawdź ostatni backup

ls -la *.sql -t | head -5

# Weryfikuj integralność backup'u

head -5 backup_file.sql
tail -5 backup_file.sql

```

### Zadania do samodzielnego wykonania

1. Wykonaj backup bazy `sklep` używając mysqldump z kompresją
2. Przywróć backup do nowej bazy o nazwie `sklep_restored`
3. Stwórz skrypt automatyzujący codzienne backup'y
4. Przetestuj point-in-time recovery używając binary logs
5. Wykonaj backup przez phpMyAdmin i porównaj rozmiar pliku z mysqldump

**Koniec lekcji**
```

<div style="text-align: center">⁂</div>

[^1]: https://phoenixnap.com/kb/how-to-backup-restore-a-mysql-database

[^2]: https://dev.mysql.com/doc/mysql-backup-excerpt/8.2/en/backup-and-recovery.html

[^3]: https://www.mysqltutorial.org/mysql-administration/mysql-backup/

[^4]: https://www.acronis.com/en/blog/posts/mysql-backup/

[^5]: https://simplebackups.com/blog/the-complete-mysqldump-guide-with-examples

[^6]: https://n2ws.com/blog/mysql-backup-methods

[^7]: https://www.devart.com/dbforge/mysql/studio/mysql-restore-dump.html

[^8]: https://www.youtube.com/watch?v=DaAbmHJUmKM

