# Lekcja: MySQL – podstawy obsługi za pomocą wiersza polecenia i z poziomu phpMyAdmin
**Czas trwania: 90 minut**  
**Zgodnie z programem nauczania PiABD-2025-2026 i wymaganiami egzaminu INF.03**

---

## Struktura lekcji (90 minut)
1. **Wprowadzenie i uruchomienie XAMPP** (15 min)
2. **MySQL CLI – wiersz polecenia** (25 min)
3. **phpMyAdmin – interfejs graficzny** (30 min)
4. **Porównanie metod i praktyczne ćwiczenia** (15 min)
5. **Podsumowanie i Q&A** (5 min)

---

## Część 1: Wprowadzenie i uruchomienie XAMPP (15 minut)

### Co to jest MySQL i XAMPP?
- **MySQL** to system zarządzania relacyjnymi bazami danych (RDBMS)
- **XAMPP** to pakiet oprogramowania zawierający Apache, MySQL, PHP i Perl
- Używamy XAMPP zgodnie z wytycznymi egzaminu INF.03

### Uruchamianie XAMPP
**KROK 1: Uruchomienie panelu XAMPP**
```
C:\xampp\xampp-control.exe
```

**KROK 2: Start usług**
- Kliknij "Start" przy Apache
- Kliknij "Start" przy MySQL
- Sprawdź czy status pokazuje "Running" (zielone tło)

### Sprawdzenie poprawności instalacji
**W przeglądarce otwórz:**
```
http://localhost
```
Powinniśmy zobaczyć stronę powitalną XAMPP.

**Sprawdzenie phpMyAdmin:**
```
http://localhost/phpmyadmin
```

---

## Część 2: MySQL CLI – wiersz polecenia (25 minut)

### Logowanie do MySQL CLI

**KROK 1: Otwórz Command Prompt jako Administrator**

**KROK 2: Przejdź do katalogu MySQL**
```cmd
cd C:\xampp\mysql\bin
```

**KROK 3: Zaloguj się do MySQL**
```cmd
mysql.exe -u root
```
*Uwaga: W świeżej instalacji XAMPP użytkownik root nie ma hasła*

### Podstawowe polecenia CLI

**Wyświetlenie dostępnych baz:**
```sql
SHOW DATABASES;
```

**Tworzenie nowej bazy:**
```sql
CREATE DATABASE szkola_test;
```

**Wybór bazy do pracy:**
```sql
USE szkola_test;
```

**Tworzenie prostej tabeli:**
```sql
CREATE TABLE uczniowie (
    id INT PRIMARY KEY AUTO_INCREMENT,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    klasa VARCHAR(10)
);
```

**Sprawdzenie struktury tabeli:**
```sql
DESCRIBE uczniowie;
```

**Dodanie przykładowych danych:**
```sql
INSERT INTO uczniowie (imie, nazwisko, klasa) VALUES 
('Jan', 'Kowalski', '4A'),
('Anna', 'Nowak', '4B'),
('Piotr', 'Wiśniewski', '4A');
```

**Wyświetlenie danych:**
```sql
SELECT * FROM uczniowie;
```

**Wyjście z MySQL CLI:**
```sql
exit;
```

### Zalety i wady CLI
**Zalety:**
- Szybkie wykonywanie zapytań
- Możliwość wykonywania skryptów
- Mała ilość zasobów systemowych
- Dostępne na każdym serwerze

**Wady:**
- Wymaga znajomości składni SQL
- Brak podpowiedzi graficznych
- Trudniejsza edycja długich zapytań

---

## Część 3: phpMyAdmin – interfejs graficzny (30 minut)

### Uruchomienie phpMyAdmin
```
http://localhost/phpmyadmin
```

### Główny interfejs phpMyAdmin

**Panel lewy:** Lista baz danych  
**Panel główny:** Obszar roboczy  
**Menu górne:** Główne funkcje

### Tworzenie bazy danych w phpMyAdmin

**KROK 1:** Kliknij zakładkę "Bazy danych"

**KROK 2:** Wpisz nazwę "szkola_gui" w polu "Utwórz bazę danych"

**KROK 3:** Wybierz kodowanie "utf8_polish_ci"

**KROK 4:** Kliknij "Utwórz"

### Tworzenie tabeli w phpMyAdmin

**KROK 1:** Wybierz bazę "szkola_gui" z panelu lewego

**KROK 2:** W polu "Utwórz tabelę" wpisz:
- Nazwa: `uczniowie`
- Liczba kolumn: `4`

**KROK 3:** Kliknij "Wykonaj"

**KROK 4:** Skonfiguruj kolumny:
```
id          INT         A_I (Auto Increment)    Klucz główny
imie        VARCHAR(50)
nazwisko    VARCHAR(50) 
klasa       VARCHAR(10)
```

**KROK 5:** Kliknij "Zapisz"

### Dodawanie danych przez phpMyAdmin

**KROK 1:** Wybierz tabelę "uczniowie"

**KROK 2:** Kliknij zakładkę "Wstaw"

**KROK 3:** Wypełnij formularz:
```
imie: Maria
nazwisko: Kowalczyk
klasa: 4C
```

**KROK 4:** Kliknij "Wykonaj"

### Przeglądanie i edycja danych

**KROK 1:** Kliknij zakładkę "Przeglądaj"

**KROK 2:** Zobaczysz listę wszystkich rekordów

**KROK 3:** Użyj ikon:
- 🖊️ Edytuj
- ❌ Usuń
- 📋 Kopiuj

### Wykonywanie zapytań SQL w phpMyAdmin

**KROK 1:** Kliknij zakładkę "SQL"

**KROK 2:** Wpisz zapytanie:
```sql
SELECT * FROM uczniowie WHERE klasa = '4A';
```

**KROK 3:** Kliknij "Wykonaj"

### Import i eksport danych

**Eksport bazy:**
**KROK 1:** Wybierz bazę danych
**KROK 2:** Kliknij zakładkę "Eksport"
**KROK 3:** Wybierz format (SQL)
**KROK 4:** Kliknij "Wykonaj"

**Import bazy:**
**KROK 1:** Kliknij zakładkę "Import"
**KROK 2:** Wybierz plik
**KROK 3:** Kliknij "Wykonaj"

### Zarządzanie użytkownikami

**KROK 1:** Kliknij "Konta użytkowników" w menu głównym

**KROK 2:** Kliknij "Dodaj konto użytkownika"

**KROK 3:** Wypełnij:
```
Nazwa użytkownika: test_user
Nazwa hosta: localhost
Hasło: test123
```

**KROK 4:** Wybierz uprawnienia globalne lub dla konkretnej bazy

**KROK 5:** Kliknij "Wykonaj"

---

## Część 4: Porównanie metod i praktyczne ćwiczenia (15 minut)

### Porównanie CLI vs phpMyAdmin

| Aspekt | MySQL CLI | phpMyAdmin |
|--------|-----------|------------|
| **Szybkość** | Bardzo szybki | Wolniejszy |
| **Łatwość użycia** | Wymaga znajomości SQL | Intuicyjny interfejs |
| **Zarządzanie dużymi danami** | Bardzo dobre | Ograniczone |
| **Tworzenie kopii** | Polecenie mysqldump | Wbudowana funkcja |
| **Praca zdalna** | SSH + tunel | Dostęp webowy |
| **Egzamin INF.03** | Wymagany | Wymagany |

### Praktyczne ćwiczenie

**Zadanie:** Utwórz bazę "biblioteka" z tabelą "ksiazki" zawierającą kolumny: id, tytul, autor, rok_wydania, dostepna.

**Wykonaj używając CLI:**
```sql
CREATE DATABASE biblioteka;
USE biblioteka;
CREATE TABLE ksiazki (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tytul VARCHAR(200),
    autor VARCHAR(100),
    rok_wydania INT,
    dostepna BOOLEAN DEFAULT TRUE
);
```

**Wykonaj używając phpMyAdmin:**
1. Utwórz bazę przez interfejs graficzny
2. Dodaj tabelę używając kreatora tabel
3. Wstaw przykładowe dane

### Kiedy używać której metody?

**Użyj CLI gdy:**
- Wykonujesz skrypty automatyzujące
- Pracujesz z dużymi ilościami danych
- Potrzebujesz maksymalnej wydajności
- Pracujesz zdalnie przez SSH

**Użyj phpMyAdmin gdy:**
- Uczysz się SQL-a
- Szybko przeglądasz dane
- Tworzysz raporty
- Zarządzasz uprawnieniami użytkowników

---

## Część 5: Podsumowanie i Q&A (5 minut)

### Kluczowe informacje dla egzaminu INF.03:

1. **Musisz umieć używać obu metod** - CLI i phpMyAdmin
2. **Podstawowe polecenia SQL** - CREATE, INSERT, SELECT, UPDATE, DELETE
3. **Tworzenie kopii zapasowych** - mysqldump lub eksport phpMyAdmin
4. **Zarządzanie użytkownikami** - CREATE USER, GRANT, REVOKE
5. **Struktura bazy danych** - tabele, klucze, relacje

### Przydatne polecenia CLI do zapamiętania:
```bash
mysql -u root -p                    # Logowanie
SHOW DATABASES;                     # Lista baz
USE nazwa_bazy;                     # Wybór bazy
SHOW TABLES;                        # Lista tabel
DESCRIBE nazwa_tabeli;              # Struktura tabeli
```

### Najważniejsze funkcje phpMyAdmin:
- Kreator tabel i baz danych
- Edytor SQL z podświetlaniem składni
- Import/eksport danych
- Zarządzanie użytkownikami
- Monitorowanie wydajności

### Zadanie domowe:
Stwórz bazę danych "sklep" z tabelami: produkty, kategorie, zamowienia. Użyj obu metod (CLI i phpMyAdmin) i porównaj czas wykonania każdej operacji.

---

## Dodatkowe materiały:
- Dokumentacja MySQL: https://dev.mysql.com/doc/
- phpMyAdmin wiki: https://wiki.phpmyadmin.net/
- Przykładowe zadania egzaminacyjne INF.03

**Koniec lekcji**
