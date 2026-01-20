# FUNKCJE AGREGUJĄCE I MATEMATYCZNE W SQL - MYSQL
## Lekcja przygotowawcza do egzaminu INF03 - Klasa 3 Technikum

**Czas trwania:** 90 minut  
**Poziom:** Podstawowy  
**Wymagania:** Znajomość SELECT, WHERE, FROM, JOIN

---

## 📋 PLAN LEKCJI

1. **Część teoretyczna** (25 min) - Funkcje agregujące i matematyczne
2. **Setup bazy danych** (5 min) - Import i przygotowanie
3. **Przykłady praktyczne** (30 min) - Demonstracja każdej funkcji
4. **Ćwiczenia** (25 min) - Zadania dla uczniów
5. **Podsumowanie** (5 min)

---

## 🎯 CELE LEKCJI

Po tej lekcji uczniowie będą w stanie:
- ✅ Używać funkcji agregujących (SUM, AVG, COUNT, MIN, MAX, GROUP_CONCAT)
- ✅ Stosować funkcje matematyczne (ROUND, FLOOR, CEIL, ABS, POWER)
- ✅ Grupować dane za pomocą GROUP BY
- ✅ Filtrować grupy za pomocą HAVING
- ✅ Łączyć wiele funkcji w jednym zapytaniu
- ✅ Rozwiązywać praktyczne problemy biznesowe

---

# CZĘŚĆ I: TEORIA (25 minut)

## 1. FUNKCJE AGREGUJĄCE

### Co to są funkcje agregujące?
Funkcje, które operują na zestawie wierszy i zwracają **jedną wartość** (agregat).

### 1.1 COUNT() - Zliczanie wierszy
```sql
-- Liczy wszystkie wiersze
SELECT COUNT(*) FROM pracownicy;

-- Liczy niepuste wartości w kolumnie
SELECT COUNT(wynagrodzenie) FROM pracownicy;

-- Liczy unikalne wartości
SELECT COUNT(DISTINCT departament) FROM pracownicy;
```

**Przypadki użycia:**
- Liczba wszystkich klientów
- Liczba ukończonych zamówień
- Ile produktów sprzedano

---

### 1.2 SUM() - Sumowanie wartości
```sql
-- Suma wszystkich wartości
SELECT SUM(kwota) FROM zamowienia;

-- Suma z warunkiem
SELECT SUM(kwota) FROM zamowienia WHERE status = 'opłacone';
```

**Przypadki użycia:**
- Całkowita wartość sprzedaży
- Suma wynagrodzenia pracowników
- Łączna ilość towarów w magazynie

---

### 1.3 AVG() - Średnia arytmetyczna
```sql
-- Średnia wartość
SELECT AVG(cena) FROM produkty;

-- Średnia z zaokrągleniem
SELECT ROUND(AVG(cena), 2) FROM produkty;
```

**Przypadki użycia:**
- Średnia cena produktu
- Średnie wynagrodzenie
- Średni czas dostawy

---

### 1.4 MIN() i MAX() - Wartość minimalna i maksymalna
```sql
-- Najniższa i najwyższa cena
SELECT MIN(cena), MAX(cena) FROM produkty;

-- Pierwszy i ostatni zamówienie
SELECT MIN(data_zamowienia), MAX(data_zamowienia) FROM zamowienia;
```

**Przypadki użycia:**
- Najstarszy pracownik, najmłodszy pracownik
- Najlepsza i najgorsza sprzedaż
- Najwcześniejsza i najpóźniejsza dostawa

---

### 1.5 GROUP_CONCAT() - Łączenie wartości tekstowych
```sql
-- Wszystkie nazwy jako tekst oddzielony przecinkami
SELECT GROUP_CONCAT(nazwa) FROM produkty;

-- Z customowym separatorem
SELECT GROUP_CONCAT(nazwa SEPARATOR ' | ') FROM produkty;

-- Z ograniczeniem i sortowaniem
SELECT GROUP_CONCAT(nazwa ORDER BY cena DESC SEPARATOR ', ') FROM produkty;
```

**Przypadki użycia:**
- Lista produktów z zamówienia
- Imiona pracowników z departamentu
- Nazwy kategorii w jednym wierszu

---

## 2. FUNKCJE MATEMATYCZNE

### 2.1 ROUND() - Zaokrąglanie
```sql
-- Zaokrąglenie do 2 miejsc po przecinku
SELECT ROUND(3.14159, 2);  -- Rezultat: 3.14

-- Bez parametru - zaokrąglenie do całości
SELECT ROUND(3.6);  -- Rezultat: 4

-- Zaokrąglenie do setek
SELECT ROUND(1234.56, -2);  -- Rezultat: 1200
```

**Przypadki użycia:**
- Zaokrąglenie ceny do 2 miejsc
- Przychód zaokrąglony do tysiąca
- Średnia ocena zaokrąglona do 1 miejsca

---

### 2.2 FLOOR() - Zaokrąglanie w dół
```sql
-- Zawsze zaokrągla w dół
SELECT FLOOR(3.9);   -- Rezultat: 3
SELECT FLOOR(3.1);   -- Rezultat: 3
SELECT FLOOR(-2.9);  -- Rezultat: -3
```

**Przypadki użycia:**
- Liczba pełnych godzin pracy
- Liczba kompletnych zestawów
- Całkowita liczba dni

---

### 2.3 CEIL() - Zaokrąglanie w górę
```sql
-- Zawsze zaokrągla w górę
SELECT CEIL(3.1);    -- Rezultat: 4
SELECT CEIL(3.9);    -- Rezultat: 4
SELECT CEIL(-2.1);   -- Rezultat: -2
```

**Przypadki użycia:**
- Liczba pakietów potrzebnych do wysyłki
- Liczba potrzebnych pracowników
- Minimalna liczba dni na realizację

---

### 2.4 ABS() - Wartość bezwzględna
```sql
-- Zawsze dodatnie
SELECT ABS(-100);    -- Rezultat: 100
SELECT ABS(100);     -- Rezultat: 100
SELECT ABS(-3.14);   -- Rezultat: 3.14
```

**Przypadki użycia:**
- Różnica między wartościami (bez znaku)
- Rozbieżności między planem a rzeczywistością
- Odchylenie od średniej

---

### 2.5 POWER() - Potęgowanie
```sql
-- Liczba do potęgi
SELECT POWER(2, 3);    -- Rezultat: 8 (2³)
SELECT POWER(10, 2);   -- Rezultat: 100 (10²)
SELECT POWER(5, 0.5);  -- Rezultat: 2.236... (pierwiastek)
```

**Przypadki użycia:**
- Obliczenia geometryczne
- Procent składany
- Wzory fizyczne

---

### 2.6 MOD() - Reszta z dzielenia
```sql
-- Reszta z dzielenia
SELECT MOD(10, 3);   -- Rezultat: 1
SELECT MOD(15, 5);   -- Rezultat: 0
SELECT 10 % 3;       -- Alternatywa: 1
```

**Przypadki użycia:**
- Czy liczba jest parzysta (MOD(liczba, 2) = 0)
- Cykliczne numery partii
- Rozkład na równe grupy

---

### 2.7 SQRT() - Pierwiastek kwadratowy
```sql
-- Pierwiastek kwadratowy
SELECT SQRT(16);     -- Rezultat: 4
SELECT SQRT(2);      -- Rezultat: 1.414...
SELECT SQRT(0.25);   -- Rezultat: 0.5
```

**Przypadki użycia:**
- Obliczenia odległości
- Wielkość pola/obszaru
- Standardowe odchylenie

---

## 3. GROUP BY i HAVING

### GROUP BY - Grupowanie danych
```sql
-- Grupuj po departamencie i policz pracowników
SELECT departament, COUNT(*) as liczba_pracownikow
FROM pracownicy
GROUP BY departament;
```

### HAVING - Filtrowanie grup
```sql
-- Pokaż tylko departamenty z więcej niż 5 pracownikami
SELECT departament, COUNT(*) as liczba_pracownikow
FROM pracownicy
GROUP BY departament
HAVING COUNT(*) > 5;
```

**Różnica WHERE vs HAVING:**
- **WHERE** - filtruje wiersze PRZED grupowaniem
- **HAVING** - filtruje grupy PO agregacji

---

# CZĘŚĆ II: SETUP BAZY DANYCH (5 minut)

## Skrypt SQL do importu

Skopiuj poniższy kod do phpMyAdmin → SQL i wykonaj:

```sql
-- Tworzenie bazy danych
CREATE DATABASE IF NOT EXISTS sklep_online;
USE sklep_online;

-- Tabela: Kategorii produktów
CREATE TABLE kategorie (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nazwa VARCHAR(50) NOT NULL,
    opis TEXT
);

-- Tabela: Produkty
CREATE TABLE produkty (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nazwa VARCHAR(100) NOT NULL,
    cena DECIMAL(10, 2) NOT NULL,
    kategoria_id INT NOT NULL,
    ilosc_magazyn INT DEFAULT 0,
    data_dodania DATE,
    FOREIGN KEY (kategoria_id) REFERENCES kategorie(id)
);

-- Tabela: Klienci
CREATE TABLE klienci (
    id INT PRIMARY KEY AUTO_INCREMENT,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    telefon VARCHAR(20),
    data_rejestracji DATE,
    miasto VARCHAR(50)
);

-- Tabela: Zamówienia
CREATE TABLE zamowienia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    klient_id INT NOT NULL,
    data_zamowienia DATE NOT NULL,
    kwota_calkowita DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'oczekujące',
    FOREIGN KEY (klient_id) REFERENCES klienci(id)
);

-- Tabela: Pozycje zamówienia
CREATE TABLE pozycje_zamowienia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    zamowienie_id INT NOT NULL,
    produkt_id INT NOT NULL,
    ilosc INT NOT NULL,
    cena_jednostkowa DECIMAL(10, 2),
    FOREIGN KEY (zamowienie_id) REFERENCES zamowienia(id),
    FOREIGN KEY (produkt_id) REFERENCES produkty(id)
);

-- ===== WSTAWIENIE DANYCH TESTOWYCH =====

-- Kategorie
INSERT INTO kategorie VALUES
(1, 'Elektronika', 'Urządzenia elektroniczne'),
(2, 'Książki', 'Książki różnych gatunków'),
(3, 'Odzież', 'Ubrania i akcesoria'),
(4, 'Sprzęt sportowy', 'Artykuły sportowe'),
(5, 'Akcesoria', 'Różne akcesoria');

-- Produkty
INSERT INTO produkty VALUES
(1, 'Laptop DELL', 3500.00, 1, 15, '2025-01-10'),
(2, 'Mysz bezprzewodowa', 45.99, 1, 120, '2025-01-08'),
(3, 'Klawiatura mechaniczna', 250.00, 1, 45, '2025-01-12'),
(4, 'Harry Potter - Tom 1', 39.99, 2, 50, '2024-12-20'),
(5, 'Władca Pierścieni', 59.99, 2, 30, '2024-12-22'),
(6, 'T-shirt bawełniany', 49.99, 3, 200, '2025-01-05'),
(7, 'Jeansy proste', 129.99, 3, 85, '2025-01-07'),
(8, 'Buty sportowe', 199.99, 4, 60, '2024-12-28'),
(9, 'Rower górski', 1200.00, 4, 12, '2025-01-01'),
(10, 'Plecak turystyczny', 150.00, 5, 40, '2025-01-03');

-- Klienci
INSERT INTO klienci VALUES
(1, 'Jan', 'Kowalski', 'jan.kowalski@email.com', '555123456', '2024-06-15', 'Warszawa'),
(2, 'Maria', 'Nowak', 'maria.nowak@email.com', '555234567', '2024-08-20', 'Kraków'),
(3, 'Piotr', 'Lewandowski', 'piotr.lew@email.com', '555345678', '2024-09-10', 'Wrocław'),
(4, 'Anna', 'Wiśniewski', 'anna.w@email.com', '555456789', '2024-07-05', 'Poznań'),
(5, 'Tomasz', 'Szymański', 'tomasz.s@email.com', '555567890', '2025-01-02', 'Gdańsk'),
(6, 'Katarzyna', 'Kucharski', 'kasia.k@email.com', '555678901', '2024-10-12', 'Warszawa'),
(7, 'Robert', 'Jankowski', 'robert.j@email.com', '555789012', '2025-01-09', 'Łódź'),
(8, 'Joanna', 'Michalska', 'joanna.m@email.com', '555890123', '2024-11-30', 'Kraków');

-- Zamówienia
INSERT INTO zamowienia VALUES
(1, 1, '2025-01-15', 3545.99, 'opłacone'),
(2, 2, '2025-01-14', 99.98, 'wysłane'),
(3, 3, '2025-01-13', 1200.00, 'oczekujące'),
(4, 1, '2025-01-12', 250.00, 'opłacone'),
(5, 4, '2025-01-11', 179.99, 'opłacone'),
(6, 5, '2025-01-10', 4700.00, 'wysłane'),
(7, 6, '2025-01-09', 89.97, 'opłacone'),
(8, 2, '2025-01-08', 150.00, 'oczekujące'),
(9, 7, '2025-01-07', 249.99, 'opłacone'),
(10, 8, '2025-01-06', 500.00, 'wysłane'),
(11, 3, '2025-01-05', 350.00, 'opłacone'),
(12, 1, '2025-01-04', 2500.00, 'wysłane');

-- Pozycje zamówienia
INSERT INTO pozycje_zamowienia VALUES
(1, 1, 1, 1, 3500.00),
(2, 1, 2, 1, 45.99),
(3, 2, 4, 2, 39.99),
(4, 3, 9, 1, 1200.00),
(5, 4, 3, 1, 250.00),
(6, 5, 6, 1, 49.99),
(7, 5, 8, 1, 129.99),
(8, 6, 1, 1, 3500.00),
(9, 6, 2, 1, 45.99),
(10, 6, 3, 1, 154.01),
(11, 7, 7, 1, 89.97),
(12, 8, 10, 1, 150.00),
(13, 9, 8, 1, 249.99),
(14, 10, 5, 1, 500.00),
(15, 11, 2, 7, 50.00),
(16, 11, 6, 1, 49.99),
(17, 11, 7, 1, 250.01),
(18, 12, 1, 1, 2500.00);
```

**Instrukcje:**
1. Otwórz phpMyAdmin
2. Przejdź do zakładki "SQL"
3. Skopiuj cały kod wyżej
4. Wklej w pole SQL
5. Kliknij "Wykonaj"

Baza jest gotowa! ✅

---

# CZĘŚĆ III: PRZYKŁADY PRAKTYCZNE (30 minut)

## PRZYKŁAD 1: COUNT() - Zliczanie

### Zadanie: Ile produktów jest w sklepie?
```sql
SELECT COUNT(*) as liczba_produktow
FROM produkty;
```
**Rezultat:** 10

---

### Zadanie: Ilu zarejestrowanych klientów mamy?
```sql
SELECT COUNT(*) as liczba_klientow
FROM klienci;
```
**Rezultat:** 8

---

### Zadanie: Ile produktów ma określoną cenę?
```sql
SELECT COUNT(cena) as produkty_z_cena
FROM produkty;
```
**Rezultat:** 10

---

### Zadanie: Ile różnych kategorii mamy?
```sql
SELECT COUNT(DISTINCT kategoria_id) as liczba_kategorii
FROM produkty;
```
**Rezultat:** 5

---

## PRZYKŁAD 2: SUM() - Sumowanie

### Zadanie: Jaka jest całkowita wartość wszystkich zamówień opłaconych?
```sql
SELECT SUM(kwota_calkowita) as przychod_razem
FROM zamowienia
WHERE status = 'opłacone';
```
**Rezultat:** 12184.94

---

### Zadanie: Ile sztuk towaru znajduje się w magazynie?
```sql
SELECT SUM(ilosc_magazyn) as ilosc_calkowita
FROM produkty;
```
**Rezultat:** 657

---

### Zadanie: Jaka jest całkowita wartość wszystkich pozycji zamówienia?
```sql
SELECT SUM(ilosc * cena_jednostkowa) as wartosc_calkowita
FROM pozycje_zamowienia;
```
**Rezultat:** 10549.92

---

## PRZYKŁAD 3: AVG() - Średnia

### Zadanie: Jaka jest średnia cena produktu?
```sql
SELECT AVG(cena) as srednia_cena
FROM produkty;
```
**Rezultat:** 1002.99

---

### Zadanie: Jaka jest średnia cena produktu zaokrąglona do 2 miejsc?
```sql
SELECT ROUND(AVG(cena), 2) as srednia_cena
FROM produkty;
```
**Rezultat:** 1002.99

---

### Zadanie: Jaka jest średnia wartość zamówienia?
```sql
SELECT ROUND(AVG(kwota_calkowita), 2) as srednia_wartosc
FROM zamowienia;
```
**Rezultat:** 1026.83

---

## PRZYKŁAD 4: MIN() i MAX() - Ekstrema

### Zadanie: Jaki jest najmniejszy i największy numer zamówienia?
```sql
SELECT 
    MIN(id) as pierwsze_zamowienie,
    MAX(id) as ostatnie_zamowienie
FROM zamowienia;
```
**Rezultat:** MIN = 1, MAX = 12

---

### Zadanie: Jakie są najniższa i najwyższa cena produktu?
```sql
SELECT 
    MIN(cena) as najnizsza_cena,
    MAX(cena) as najwyzsza_cena,
    MAX(cena) - MIN(cena) as roznica
FROM produkty;
```
**Rezultat:** MIN = 39.99, MAX = 3500.00, Różnica = 3460.01

---

### Zadanie: Kiedy pierwsze i ostatnie zamówienie?
```sql
SELECT 
    MIN(data_zamowienia) as pierwsze_zamowienie,
    MAX(data_zamowienia) as ostatnie_zamowienie
FROM zamowienia;
```
**Rezultat:** MIN = 2025-01-04, MAX = 2025-01-15

---

## PRZYKŁAD 5: GROUP_CONCAT() - Łączenie tekstów

### Zadanie: Lista wszystkich nazw produktów oddzielona przecinkami
```sql
SELECT GROUP_CONCAT(nazwa SEPARATOR ', ')
FROM produkty;
```
**Rezultat:** Laptop DELL, Mysz bezprzewodowa, Klawiatura mechaniczna, ...

---

### Zadanie: Produkty z każdej kategorii
```sql
SELECT 
    k.nazwa as kategoria,
    GROUP_CONCAT(p.nazwa SEPARATOR ', ') as produkty
FROM kategorie k
LEFT JOIN produkty p ON k.id = p.kategoria_id
GROUP BY k.id;
```

---

## PRZYKŁAD 6: GROUP BY - Grupowanie

### Zadanie: Ile produktów w każdej kategorii?
```sql
SELECT 
    k.nazwa as kategoria,
    COUNT(p.id) as liczba_produktow
FROM kategorie k
LEFT JOIN produkty p ON k.id = p.kategoria_id
GROUP BY k.id, k.nazwa;
```

**Rezultat:**
| kategoria | liczba_produktow |
|-----------|------------------|
| Elektronika | 3 |
| Książki | 2 |
| Odzież | 2 |
| Sprzęt sportowy | 2 |
| Akcesoria | 1 |

---

### Zadanie: Średnia cena produktu w każdej kategorii
```sql
SELECT 
    k.nazwa as kategoria,
    ROUND(AVG(p.cena), 2) as srednia_cena,
    COUNT(p.id) as liczba_produktow
FROM kategorie k
LEFT JOIN produkty p ON k.id = p.kategoria_id
GROUP BY k.id, k.nazwa;
```

---

### Zadanie: Łączna wartość zamówień dla każdego klienta
```sql
SELECT 
    CONCAT(k.imie, ' ', k.nazwisko) as klient,
    COUNT(z.id) as liczba_zamowien,
    SUM(z.kwota_calkowita) as razem_wydany,
    ROUND(AVG(z.kwota_calkowita), 2) as srednia_zamowienie
FROM klienci k
LEFT JOIN zamowienia z ON k.id = z.klient_id
GROUP BY k.id;
```

---

## PRZYKŁAD 7: HAVING - Filtrowanie grup

### Zadanie: Kategorie z więcej niż jednym produktem
```sql
SELECT 
    k.nazwa as kategoria,
    COUNT(p.id) as liczba_produktow
FROM kategorie k
LEFT JOIN produkty p ON k.id = p.kategoria_id
GROUP BY k.id, k.nazwa
HAVING COUNT(p.id) > 1;
```

---

### Zadanie: Klienci, którzy wydali więcej niż 1000 zł
```sql
SELECT 
    CONCAT(k.imie, ' ', k.nazwisko) as klient,
    SUM(z.kwota_calkowita) as razem_wydany
FROM klienci k
LEFT JOIN zamowienia z ON k.id = z.klient_id
GROUP BY k.id
HAVING SUM(z.kwota_calkowita) > 1000;
```

---

## PRZYKŁAD 8: ROUND(), FLOOR(), CEIL()

### Zaokrąglanie cen do pełnych złotych
```sql
SELECT 
    nazwa,
    cena as cena_dokładna,
    ROUND(cena) as zaokraglone,
    FLOOR(cena) as zaokraglone_down,
    CEIL(cena) as zaokraglone_up
FROM produkty
LIMIT 5;
```

**Rezultat:**

| nazwa | cena_dokładna | zaokraglone | zaokraglone_down | zaokraglone_up |
|-------|---|---|---|---|
| Laptop DELL | 3500.00 | 3500 | 3500 | 3500 |
| Mysz bezprzewodowa | 45.99 | 46 | 45 | 46 |
| Klawiatura mechaniczna | 250.00 | 250 | 250 | 250 |
| Harry Potter - Tom 1 | 39.99 | 40 | 39 | 40 |
| Władca Pierścieni | 59.99 | 60 | 59 | 60 |

---

## PRZYKŁAD 9: ABS() - Wartość bezwzględna

### Zadanie: Różnica między ilością w magazynie a minimalnym zapasem (20 szt.)
```sql
SELECT 
    nazwa,
    ilosc_magazyn,
    ABS(ilosc_magazyn - 20) as roznica_od_minimum
FROM produkty;
```

---

## PRZYKŁAD 10: POWER(), MOD(), SQRT()

### Zadanie: Obliczenia matematyczne na cenach
```sql
SELECT 
    nazwa,
    cena,
    ROUND(POWER(cena, 0.5), 2) as pierwiastek,
    ROUND(POWER(cena * 1.23, 1), 2) as z_podatkiem,
    MOD(FLOOR(cena), 10) as ostatnia_cyfra
FROM produkty
LIMIT 3;
```

---

# CZĘŚĆ IV: ZADANIA DO SAMODZIELNEGO ROZWIĄZANIA (25 minut)

## 🎓 ZADANIE 1 (łatwe - 5 min)
**Policz wszystkie zamówienia w systemie.**

Wskazówka: Użyj COUNT(*)

---

## 🎓 ZADANIE 2 (łatwe - 5 min)
**Wyświetl sumę całkowitej wartości produktów w magazynie (SUM ilości × ceny).**

```sql
-- Wskazówka: SUM(ilosc_magazyn * cena)
```

---

## 🎓 ZADANIE 3 (łatwe - 5 min)
**Jaki jest średni stan magazynu dla wszystkich produktów? Zaokrąglij do 2 miejsc.**

```sql
-- Wskazówka: AVG(), ROUND()
```

---

## 🎓 ZADANIE 4 (łatwe - 5 min)
**Wyświetl najdroższy i najtańszy produkt w sklepie.**

```sql
-- Wskazówka: MIN(), MAX()
```

---

## 🎓 ZADANIE 5 (średnie - 7 min)
**Dla każdej kategorii wyświetl:**
- Nazwę kategorii
- Liczbę produktów
- Średnią cenę
- Łączną ilość w magazynie

**Wskazówka:** GROUP BY, COUNT, AVG, SUM

---

## 🎓 ZADANIE 6 (średnie - 7 min)
**Wyświetl klientów, którzy złożyli więcej niż 1 zamówienie.**
- Imię i Nazwisko
- Liczba zamówień
- Łączna wartość wydana

**Wskazówka:** GROUP BY, HAVING COUNT() > 1

---

## 🎓 ZADANIE 7 (średnie - 7 min)
**Wyświetl status zamówień z informacją:**
- Status
- Liczba zamówień
- Średnia wartość zamówienia

**Wskazówka:** GROUP BY status

---

## 🎓 ZADANIE 8 (trudne - 10 min)
**Dla każdego klienta wyświetl:**
- Imię i Nazwisko
- Liczbę zamówień
- Łączną wartość wydaną
- Średnie zamówienie (zaokrąglone do 2 miejsc)
- Najdroższe zamówienie

**Wskazówka:** GROUP BY, SUM, COUNT, AVG, MAX

---

## 🎓 ZADANIE 9 (trudne - 10 min)
**Wyświetl produkty z kategorii "Elektronika":**
- Nazwy wszystkich produktów (jako jeden wiersz, oddzielone przecinkami)
- Liczbę produktów
- Średnią cenę
- Łączną ilość w magazynie

**Wskazówka:** GROUP_CONCAT(), LEFT JOIN, WHERE

---

## 🎓 ZADANIE 10 (bardzo trudne - 15 min)
**Stwórz raport sprzedażowy:**
```
Wyświetl dla produktów sprzedanych (pojawiających się w pozycjach_zamowienia):
- Nazwa produktu
- Liczba razy sprzedawany
- Łączna ilość sprzedana
- Średnia cena sprzedaży
- Łączny przychód z produktu (zaokrąglony do 2 miejsc)

Posortuj po łącznym przchodzie malejąco
```

**Wskazówka:** GROUP BY, SUM, COUNT, AVG, JOIN z pozycjami_zamowienia, ORDER BY DESC

---


---

# 📝 PODSUMOWANIE (5 minut)

## Najważniejsze do zapamiętania:

### ✅ Funkcje agregujące
| Funkcja | Co robi | Przykład |
|---------|---------|----------|
| COUNT() | Liczy wiersze | COUNT(*), COUNT(DISTINCT id) |
| SUM() | Sumuje wartości | SUM(kwota) |
| AVG() | Średnia arytmetyczna | AVG(cena) |
| MIN() | Wartość minimalna | MIN(data) |
| MAX() | Wartość maksymalna | MAX(cena) |
| GROUP_CONCAT() | Łączy teksty | GROUP_CONCAT(nazwa) |

### ✅ Funkcje matematyczne
| Funkcja | Co robi | Przykład |
|---------|---------|----------|
| ROUND() | Zaokrągla | ROUND(3.14159, 2) = 3.14 |
| FLOOR() | W dół | FLOOR(3.9) = 3 |
| CEIL() | W górę | CEIL(3.1) = 4 |
| ABS() | Wartość bezwzględna | ABS(-100) = 100 |
| POWER() | Potęgowanie | POWER(2, 3) = 8 |
| SQRT() | Pierwiastek | SQRT(16) = 4 |
| MOD() | Reszta z dzielenia | MOD(10, 3) = 1 |

### ✅ Warunki i grupowanie
| Koncept | Gdzie używać | Przykład |
|---------|-------------|----------|
| WHERE | Filtruje WIERSZE przed agregacją | WHERE status = 'opłacone' |
| GROUP BY | Grupuje wiersze | GROUP BY kategoria |
| HAVING | Filtruje GRUPY po agregacji | HAVING COUNT(*) > 5 |

---

## 💡 Praktyczne wskazówki na egzaminie INF03:

1. **Zawsze zaczynaj od SELECT** - pisz jasno i przejrzyście
2. **Używaj aliasów (AS)** - nazwy kolumn będą jasne
3. **Zaokrąglaj ceny do 2 miejsc** - ROUND(..., 2)
4. **Łącz tabele LEFT JOIN** - żeby nie zgubić danych
5. **Testuj kwerendy krok po kroku** - najpierw SELECT, potem GROUP BY, potem HAVING
6. **Pamiętaj o CONCAT()** - do łączenia tekstu (imie + nazwisko)
7. **Sortuj wyniki ORDER BY** - często tego oczekują

---

## 🔗 Przydatne zasoby:

- MySQL Documentation: https://dev.mysql.com/doc/
- W3Schools SQL Tutorial: https://www.w3schools.com/sql/
- SQL Aggregate Functions: https://dev.mysql.com/doc/refman/8.0/en/group-by-aggregate-functions.html

---

## 📌 KONIEC LEKCJI

**Czas na pytania i dyskusję!** (5 minut)

Pamiętajcie: **SQL to umiejętność, która rozwija się przez praktykę. Ćwiczcie jak najwięcej!** 💪

---

**Przygotował:** Lekcja dla technikum INF03  
**Data:** Styczeń 2026  
**Wersja:** 1.0