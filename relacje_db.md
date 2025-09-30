# Relacje w bazach danych MySQL

## Wprowadzenie

Relacje w bazach danych to sposób określenia, w jaki dane w jednej tabeli są powiązane z danymi w innej tabeli. W systemach zarządzania relacyjnymi bazami danych (RDBMS) termin "relacyjny" odnosi się właśnie do tabel z relacjami. Relacje między tabelami są tworzone za pomocą kluczy, gdzie klucz w jednej tabeli normalnie odnosi się do klucza w innej tabeli.

## Rodzaje relacji w MySQL

Istnieją trzy główne typy relacji w bazach danych:

1. **Jeden do jednego (1:1)** - jeden rekord w jednej tabeli odnosi się do jednego rekordu w drugiej tabeli
2. **Jeden do wielu (1:M)** - jeden rekord w jednej tabeli odnosi się do wielu rekordów w drugiej tabeli  
3. **Wiele do wielu (M:M)** - wiele rekordów w jednej tabeli odnosi się do wielu rekordów w drugiej tabeli

---

## Relacja Jeden do Jednego (1:1)

### Opis
W relacji jeden do jednego każdy rekord w pierwszej tabeli odpowiada dokładnie jednemu rekordowi w drugiej tabeli. Jest to najmniej używany typ relacji w praktyce.

### Graficzna reprezentacja
```

Tabela: Studenci          Tabela: Adresy
+----+----------+         +----------+------------+----------+
| Id | Imie     |  ←──→   | AdresId  | Adres      | StudentId|
+----+----------+         +----------+------------+----------+
| 1  | Jan      |         | 1001     | Warszawa   | 1        |
| 2  | Maria    |         | 1002     | Kraków     | 2        |
| 3  | Piotr    |         | 1003     | Gdańsk     | 3        |
+----+----------+         +----------+------------+----------+

```

### Implementacja SQL DDL

```

-- Tworzenie bazy danych
CREATE DATABASE szkola;
USE szkola;

-- Tworzenie tabeli głównej (Studenci)
CREATE TABLE studenci (
id INT PRIMARY KEY AUTO_INCREMENT,
imie VARCHAR(40) NOT NULL,
klasa VARCHAR(20),
wiek INT
);

-- Tworzenie tabeli powiązanej (Adresy)
CREATE TABLE adresy (
adres_id INT PRIMARY KEY,
adres VARCHAR(100) NOT NULL,
student_id INT NOT NULL UNIQUE,
FOREIGN KEY (student_id) REFERENCES studenci(id)
ON DELETE CASCADE
ON UPDATE CASCADE
);

-- Wstawianie przykładowych danych
INSERT INTO studenci VALUES
(1, 'Jan', 'Pierwsza', 7),
(2, 'Maria', 'Druga', 8),
(3, 'Piotr', 'Trzecia', 9);

INSERT INTO adresy VALUES
(1001, 'Warszawa, ul. Główna 1', 1),
(1002, 'Kraków, ul. Długa 5', 2),
(1003, 'Gdańsk, ul. Morska 10', 3);

```

### Kluczowe cechy relacji 1:1
- Klucz obcy w tabeli podrzędnej ma ograniczenie `UNIQUE`
- Każdy student ma dokładnie jeden adres
- Każdy adres należy do dokładnie jednego studenta

---

## Relacja Jeden do Wielu (1:M)

### Opis
W relacji jeden do wielu jeden rekord w tabeli głównej może być powiązany z wieloma rekordami w tabeli podrzędnej. Jest to najczęściej używany typ relacji w systemach bazodanowych.

### Graficzna reprezentacja
```
Tabela: Kategorie                    Tabela: Produkty
+-------------+------------+         +----------+-----------+-------+-------------+
| kategoria_id| nazwa      |         | produkt_id| nazwa    | cena  | kategoria_id|
+-------------+------------+         +----------+-----------+-------+-------------+
| 1           | Elektronika| ────────→ 1        | Laptop    | 2500  | 1           |
|             |            |         | 2        | Telefon   | 800   | 1           |
|             |            |         | 3        | Tablet    | 1200  | 1           |
+-------------+------------+         +----------+-----------+-------+-------------+
| 2           | Książki    | ────────→ 4        | Powieść   | 25    | 2           |
|             |            |         | 5        | Podręcznik| 89    | 2           |
+-------------+------------+         +----------+-----------+-------+-------------+
| 3           | Ubrania    | ────────→ 6        | Koszula   | 120   | 3           |
+-------------+------------+         +----------+-----------+-------+-------------+

```

### Implementacja SQL DDL

```

-- Tworzenie bazy danych
CREATE DATABASE sklep;
USE sklep;

-- Tworzenie tabeli głównej (strona "jeden")
CREATE TABLE kategorie (
kategoria_id INT AUTO_INCREMENT PRIMARY KEY,
nazwa VARCHAR(50) NOT NULL
);

-- Tworzenie tabeli podrzędnej (strona "wiele")
CREATE TABLE produkty (
produkt_id INT AUTO_INCREMENT PRIMARY KEY,
nazwa VARCHAR(255) NOT NULL,
cena DECIMAL(10, 2) NOT NULL,
kategoria_id INT NOT NULL,
FOREIGN KEY (kategoria_id) REFERENCES kategorie(kategoria_id)
ON DELETE RESTRICT
ON UPDATE CASCADE
);

-- Wstawianie przykładowych danych
INSERT INTO kategorie (nazwa) VALUES
('Elektronika'),
('Książki'),
('Ubrania');

INSERT INTO produkty (nazwa, cena, kategoria_id) VALUES
('Laptop', 2500.00, 1),
('Telefon', 800.00, 1),
('Tablet', 1200.00, 1),
('Powieść kryminalana', 25.00, 2),
('Podręcznik MySQL', 89.00, 2),
('Koszula', 120.00, 3);

```

### Kluczowe cechy relacji 1:M
- Klucz obcy znajduje się w tabeli po stronie "wiele" 
- Jedna kategoria może mieć wiele produktów
- Każdy produkt należy do dokładnie jednej kategorii
- Używamy `ON DELETE RESTRICT` aby zapobiec usunięciu kategorii mającej produkty 

---

## Relacja Wiele do Wielu (M:M)

### Opis
W relacji wiele do wielu wiele rekordów w pierwszej tabeli może być powiązanych z wieloma rekordami w drugiej tabeli . Relacja ta wymaga utworzenia tabeli pośredniczącej (tabeli łączącej).

### Graficzna reprezentacja
```
Tabela: Studenci              Tabela: student_przedmiot         Tabela: Przedmioty
+----------+----------+       +----------+-------------+       +-------------+------------+
| student_id| imie    |       | student_id| przedmiot_id|      | przedmiot_id| nazwa      |
+----------+----------+       +----------+-------------+       +-------------+------------+
| 1        | Jan      |───────→ 1        | 1           |───────→ 1           | Matematyka |
|          |          |       | 1        | 2           |───────→ 2           | Historia   |
+----------+----------+       +----------+-------------+       +-------------+------------+
| 2        | Maria    |───────→ 2        | 1           |───────→ 1           | Matematyka |
|          |          |       | 2        | 3           |───────→ 3           | Fizyka     |
+----------+----------+       +----------+-------------+       +-------------+------------+
| 3        | Piotr    |───────→ 3        | 2           |───────→ 2           | Historia   |
|          |          |       | 3        | 3           |───────→ 3           | Fizyka     |
+----------+----------+       +----------+-------------+       +-------------+------------+

```

### Implementacja SQL DDL

```

-- Tworzenie bazy danych
CREATE DATABASE szkola_przedmioty;
USE szkola_przedmioty;

-- Tworzenie pierwszej tabeli głównej
CREATE TABLE studenci (
student_id INT AUTO_INCREMENT PRIMARY KEY,
imie VARCHAR(50) NOT NULL,
nazwisko VARCHAR(50) NOT NULL,
klasa VARCHAR(20)
);

-- Tworzenie drugiej tabeli głównej
CREATE TABLE przedmioty (
przedmiot_id INT AUTO_INCREMENT PRIMARY KEY,
nazwa VARCHAR(100) NOT NULL,
opis TEXT
);

-- Tworzenie tabeli pośredniczącej (junction table)
CREATE TABLE student_przedmiot (
student_id INT NOT NULL,
przedmiot_id INT NOT NULL,
data_zapisu DATE DEFAULT CURRENT_DATE,
ocena DECIMAL(3,2),
PRIMARY KEY (student_id, przedmiot_id),
FOREIGN KEY (student_id) REFERENCES studenci(student_id)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (przedmiot_id) REFERENCES przedmioty(przedmiot_id)
ON DELETE CASCADE
ON UPDATE CASCADE
);

-- Wstawianie przykładowych danych
INSERT INTO studenci (imie, nazwisko, klasa) VALUES
('Jan', 'Kowalski', '3A'),
('Maria', 'Nowak', '3A'),
('Piotr', 'Wiśniewski', '3B');

INSERT INTO przedmioty (nazwa, opis) VALUES
('Matematyka', 'Podstawy algebry i geometrii'),
('Historia', 'Historia Polski i świata'),
('Fizyka', 'Mechanika i termodynamika');

INSERT INTO student_przedmiot (student_id, przedmiot_id, ocena) VALUES
(1, 1, 4.5),  -- Jan - Matematyka
(1, 2, 3.8),  -- Jan - Historia
(2, 1, 5.0),  -- Maria - Matematyka
(2, 3, 4.2),  -- Maria - Fizyka
(3, 2, 3.5),  -- Piotr - Historia
(3, 3, 4.0);  -- Piotr - Fizyka

```

### Kluczowe cechy relacji M:M
- Wymaga tabeli pośredniczącej (junction table) 
- Tabela pośrednicząca ma klucz główny złożony z kluczy obcych 
- Każdy student może uczęszczać na wiele przedmiotów
- Każdy przedmiot może mieć wielu studentów
- Tabela pośrednicząca może zawierać dodatkowe atrybuty (np. ocena, data zapisu)

---

## Opcje kluczy obcych (Foreign Key Options)

### ON DELETE i ON UPDATE
MySQL oferuje różne opcje dla akcji referencyjnych:

```

-- CASCADE - automatycznie usuwa/aktualizuje powiązane rekordy
FOREIGN KEY (kategoria_id) REFERENCES kategorie(kategoria_id)
ON DELETE CASCADE
ON UPDATE CASCADE

-- RESTRICT - blokuje usunięcie/aktualizację jeśli istnieją powiązane rekordy
FOREIGN KEY (kategoria_id) REFERENCES kategorie(kategoria_id)
ON DELETE RESTRICT
ON UPDATE RESTRICT

-- SET NULL - ustawia NULL w powiązanych rekordach
FOREIGN KEY (kategoria_id) REFERENCES kategorie(kategoria_id)
ON DELETE SET NULL
ON UPDATE SET NULL

```

## Przykładowe zapytania JOIN

### Pobieranie danych z relacji 1:M
```

-- Produkty z nazwami kategorii
SELECT p.nazwa AS produkt, k.nazwa AS kategoria, p.cena
FROM produkty p
JOIN kategorie k ON p.kategoria_id = k.kategoria_id;

```

### Pobieranie danych z relacji M:M
```

-- Studenci z ich przedmiotami i ocenami
SELECT s.imie, s.nazwisko, p.nazwa AS przedmiot, sp.ocena
FROM studenci s
JOIN student_przedmiot sp ON s.student_id = sp.student_id
JOIN przedmioty p ON sp.przedmiot_id = p.przedmiot_id
ORDER BY s.nazwisko, p.nazwa;

```

## Podsumowanie

Relacje w bazach danych MySQL są fundamentem właściwego projektowania struktury danych. Wybór odpowiedniego typu relacji zależy od logiki biznesowej i wymagań aplikacji. Klucze obce wraz z odpowiednimi ograniczeniami zapewniają integralność danych i spójność między tabelami.

**Najważniejsze zasady:**
- Relacja 1:1 - klucz obcy z ograniczeniem UNIQUE
- Relacja 1:M - klucz obcy w tabeli po stronie "wiele"  
- Relacja M:M - tabela pośrednicząca z kluczem głównym złożonym
- Zawsze używaj odpowiednich opcji ON DELETE i ON UPDATE
