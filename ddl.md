# Lekcja: SQL DDL (MySQL) – tworzenie bazy danych, tworzenie tabel, powiązania między tabelami, modyfikacja struktury bazy danych, usuwanie elementów bazy danych

**Czas trwania: 90 minut**  
**Zgodnie z programem nauczania PiABD-2025-2026 i wymaganiami egzaminu INF.03**



## Struktura lekcji (90 minut)
1. **Wprowadzenie do DDL** (10 min)
2. **Tworzenie bazy danych** (15 min)
3. **Tworzenie tabel i typy danych** (25 min)
4. **Powiązania między tabelami** (20 min)
5. **Modyfikacja struktury bazy** (15 min)
6. **Usuwanie elementów bazy** (5 min)



## Część 1: Wprowadzenie do DDL (10 minut)

### Co to jest DDL?
**DDL (Data Definition Language)** – język definicji danych służący do tworzenia i modyfikowania struktury bazy danych.

### Podstawowe polecenia DDL:
- `CREATE` – tworzenie nowych obiektów
- `ALTER` – modyfikacja istniejących obiektów  
- `DROP` – usuwanie obiektów
- `TRUNCATE` – usuwanie zawartości tabeli

### Różnica DDL vs DML
- **DDL** – struktura bazy (tabele, kolumny, indeksy)
- **DML** – dane w bazie (INSERT, UPDATE, DELETE, SELECT)

---

## Część 2: Tworzenie bazy danych (15 minut)

### Podstawowa składnia CREATE DATABASE

```

CREATE DATABASE nazwa_bazy;

```

### Praktyczny przykład:

**KROK 1: Stworzenie prostej bazy danych**
```

CREATE DATABASE sklep_internetowy;

```

**KROK 2: Sprawdzenie czy baza została utworzona**
```

SHOW DATABASES;

```

### Tworzenie bazy z kodowaniem UTF-8

```

CREATE DATABASE sklep_internetowy
CHARACTER SET utf8mb4
COLLATE utf8mb4_polish_ci;

```

**Wyjaśnienie:**
- `utf8mb4` – obsługa pełnego Unicode (w tym emoji)
- `utf8mb4_polish_ci` – reguły sortowania polskie, bez rozróżniania wielkości liter

### Wybór bazy do pracy

```

USE sklep_internetowy;

```

### Sprawdzenie aktualnie wybranej bazy

```

SELECT DATABASE();

```

---

## Część 3: Tworzenie tabel i typy danych (25 minut)

### Podstawowa składnia CREATE TABLE

```

CREATE TABLE nazwa_tabeli (
kolumna1 typ_danych ograniczenia,
kolumna2 typ_danych ograniczenia,
PRIMARY KEY (kolumna_klucz)
);

```

### Najważniejsze typy danych w MySQL

| Typ | Opis | Przykład |
|-----|------|----------|
| `INT` | Liczba całkowita | `id INT` |
| `VARCHAR(n)` | Tekst o zmiennej długości | `nazwa VARCHAR(100)` |
| `TEXT` | Długi tekst | `opis TEXT` |
| `DECIMAL(m,d)` | Liczba dziesiętna | `cena DECIMAL(10,2)` |
| `DATE` | Data | `data_urodzenia DATE` |
| `DATETIME` | Data i czas | `utworzono DATETIME` |
| `BOOLEAN` | Wartość logiczna | `aktywny BOOLEAN` |

### Praktyczny przykład 1: Tabela klienci

```

CREATE TABLE klienci (
id INT PRIMARY KEY AUTO_INCREMENT,
imie VARCHAR(50) NOT NULL,
nazwisko VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
telefon VARCHAR(15),
data_rejestracji DATE,
aktywny BOOLEAN DEFAULT TRUE
);

```

**Omówienie ograniczeń:**
- `PRIMARY KEY` – klucz główny, unikalny identyfikator
- `AUTO_INCREMENT` – automatyczne zwiększanie wartości
- `NOT NULL` – pole wymagane
- `UNIQUE` – wartości muszą być unikalne
- `DEFAULT` – wartość domyślna

### Praktyczny przykład 2: Tabela produkty

```

CREATE TABLE produkty (
id INT PRIMARY KEY AUTO_INCREMENT,
nazwa VARCHAR(200) NOT NULL,
opis TEXT,
cena DECIMAL(10,2) NOT NULL,
ilosc_magazyn INT DEFAULT 0,
kategoria_id INT,
utworzono DATETIME DEFAULT CURRENT_TIMESTAMP
);

```

### Sprawdzenie struktury tabeli

```

DESCRIBE produkty;
-- lub
SHOW COLUMNS FROM produkty;

```

### Wyświetlenie wszystkich tabel w bazie

```

SHOW TABLES;

```

---

## Część 4: Powiązania między tabelami (20 minut)

### Teoria kluczy obcych
**Klucz obcy (FOREIGN KEY)** – kolumna wskazująca na klucz główny innej tabeli, tworząca relację między tabelami.

### Praktyczny przykład: System zamówień

**KROK 1: Tabela kategorie**
```

CREATE TABLE kategorie (
id INT PRIMARY KEY AUTO_INCREMENT,
nazwa VARCHAR(100) NOT NULL,
opis TEXT
);

```

**KROK 2: Modyfikacja tabeli produkty (dodanie klucza obcego)**
```

ALTER TABLE produkty
ADD CONSTRAINT fk_produkty_kategoria
FOREIGN KEY (kategoria_id) REFERENCES kategorie(id);

```

**KROK 3: Tabela zamowienia**
```

CREATE TABLE zamowienia (
id INT PRIMARY KEY AUTO_INCREMENT,
klient_id INT NOT NULL,
data_zamowienia DATETIME DEFAULT CURRENT_TIMESTAMP,
status VARCHAR(20) DEFAULT 'nowe',
wartosc_total DECIMAL(10,2),
FOREIGN KEY (klient_id) REFERENCES klienci(id)
);

```

**KROK 4: Tabela szczegoly_zamowienia**
```

CREATE TABLE szczegoly_zamowienia (
id INT PRIMARY KEY AUTO_INCREMENT,
zamowienie_id INT NOT NULL,
produkt_id INT NOT NULL,
ilosc INT NOT NULL,
cena_jednostkowa DECIMAL(10,2) NOT NULL,
FOREIGN KEY (zamowienie_id) REFERENCES zamowienia(id),
FOREIGN KEY (produkt_id) REFERENCES produkty(id)
);

```

### Opcje dla kluczy obcych

```

FOREIGN KEY (kolumna) REFERENCES tabela_docelowa(kolumna)
ON DELETE CASCADE    -- usuń powiązane rekordy
ON DELETE SET NULL   -- ustaw NULL w powiązanych rekordach
ON UPDATE CASCADE    -- aktualizuj powiązane rekordy

```

### Sprawdzenie relacji w bazie

```

SELECT
TABLE_NAME,
COLUMN_NAME,
REFERENCED_TABLE_NAME,
REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'sklep_internetowy'
AND REFERENCED_TABLE_NAME IS NOT NULL;

```

---

## Część 5: Modyfikacja struktury bazy (15 minut)

### Dodawanie kolumn do tabeli

```

ALTER TABLE klienci
ADD COLUMN adres VARCHAR(200);

```

### Dodawanie wielu kolumn jednocześnie

```

ALTER TABLE klienci
ADD COLUMN miasto VARCHAR(50),
ADD COLUMN kod_pocztowy VARCHAR(10);

```

### Modyfikacja typu kolumny

```

ALTER TABLE klienci
MODIFY COLUMN telefon VARCHAR(20);

```

### Zmiana nazwy kolumny

```

ALTER TABLE klienci
CHANGE COLUMN aktywny czy_aktywny BOOLEAN DEFAULT TRUE;

```

### Dodawanie indeksu

```

ALTER TABLE klienci
ADD INDEX idx_email (email);

```

### Dodawanie klucza obcego do istniejącej tabeli

```

ALTER TABLE produkty
ADD CONSTRAINT fk_produkty_dostawca
FOREIGN KEY (dostawca_id) REFERENCES dostawcy(id);

```

### Usuwanie kolumny

```

ALTER TABLE klienci
DROP COLUMN kod_pocztowy;

```

### Usuwanie indeksu

```

ALTER TABLE klienci
DROP INDEX idx_email;

```

### Usuwanie klucza obcego

```

ALTER TABLE produkty
DROP FOREIGN KEY fk_produkty_kategoria;

```

---

## Część 6: Usuwanie elementów bazy (5 minut)

### Usuwanie tabeli

```

DROP TABLE nazwa_tabeli;

```

**Uwaga:** Najpierw usuń tabele z kluczami obcymi!

### Przykład poprawnej kolejności usuwania

```

DROP TABLE szczegoly_zamowienia;
DROP TABLE zamowienia;
DROP TABLE produkty;
DROP TABLE kategorie;
DROP TABLE klienci;

```

### Usuwanie zawartości tabeli (struktura zostaje)

```

TRUNCATE TABLE nazwa_tabeli;

```

### Usuwanie bazy danych

```

DROP DATABASE sklep_internetowy;

```

**OSTRZEŻENIE:** To działanie jest nieodwracalne!

---

## Podsumowanie i kluczowe informacje dla egzaminu INF.03

### Najważniejsze polecenia DDL:
1. `CREATE DATABASE` – tworzenie bazy
2. `CREATE TABLE` – tworzenie tabeli
3. `ALTER TABLE` – modyfikacja tabeli
4. `DROP TABLE/DATABASE` – usuwanie

### Kluczowe typy danych:
- `INT` – liczby całkowite
- `VARCHAR(n)` – teksty o zmiennej długości
- `DECIMAL(m,d)` – liczby dziesiętne
- `DATE`, `DATETIME` – daty

### Ograniczenia (CONSTRAINTS):
- `PRIMARY KEY` – klucz główny
- `FOREIGN KEY` – klucz obcy
- `NOT NULL` – pole wymagane
- `UNIQUE` – wartości unikalne
- `DEFAULT` – wartość domyślna

### Praktyczne wskazówki:
1. Zawsze planuj strukturę bazy przed tworzeniem
2. Używaj odpowiednich typów danych (nie VARCHAR dla wszystkiego)
3. Definiuj klucze obce dla zachowania integralności
4. Twórz kopie zapasowe przed modyfikacją struktury
5. Testuj zmiany na kopii testowej

### Częste błędy na egzaminie:
- Nieprawidłowa kolejność usuwania tabel z kluczami obcymi
- Zapomnienie o NOT NULL dla wymaganych pól
- Używanie TEXT zamiast VARCHAR dla krótkich tekstów
- Brak zdefiniowania klucza głównego

### Zadanie do samodzielnej pracy:
Utwórz bazę danych "biblioteka" z tabelami: autorzy, ksiazki, czytelnicy, wypozyczenia. Zdefiniuj odpowiednie relacje między tabelami.

```



[^1]: https://www.youtube.com/watch?v=UgdmKnGt17Y

[^2]: https://www.youtube.com/watch?v=Jl-HuCb4Qig

[^3]: https://www.youtube.com/watch?v=RBQk_bhsu6w

