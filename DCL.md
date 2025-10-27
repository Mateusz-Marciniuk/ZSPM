# Lekcja: SQL DCL (MySQL) – tworzenie, usuwanie i zarządzanie użytkownikami i uprawnieniami

**Czas trwania: 90 minut**  

---

## Struktura lekcji (90 minut)
1. **Wprowadzenie do DCL** (10 min)
2. **Tworzenie użytkowników** (20 min)
3. **Nadawanie uprawnień (GRANT)** (25 min)
4. **Odbieranie uprawnień (REVOKE)** (15 min)
5. **Zarządzanie hasłami i usuwanie użytkowników** (15 min)
6. **Praktyczne ćwiczenia i najlepsze praktyki** (5 min)

---

## Część 1: Wprowadzenie do DCL (10 minut)

### Co to jest DCL?
**DCL (Data Control Language)** – język kontroli danych służący do zarządzania uprawnieniami użytkowników oraz kontroli dostępu do obiektów bazy danych. Jest kluczowy dla bezpieczeństwa systemu bazodanowego.

### Podstawowe polecenia DCL:
- `CREATE USER` – tworzenie nowych użytkowników
- `DROP USER` – usuwanie użytkowników
- `GRANT` – nadawanie uprawnień
- `REVOKE` – odbieranie uprawnień
- `SET PASSWORD` / `ALTER USER` – zarządzanie hasłami
- `SHOW GRANTS` – wyświetlanie uprawnień

### Zasada najmniejszych uprawnień
Użytkownik powinien otrzymać tylko te uprawnienia, które są niezbędne do wykonywania jego zadań. Nadmierne uprawnienia stanowią zagrożenie bezpieczeństwa.

### Przygotowanie środowiska testowego

```

-- Sprawdzenie aktualnego użytkownika
SELECT USER(), CURRENT_USER();

-- Wyświetlenie wszystkich użytkowników (wymaga uprawnień administratora)
SELECT user, host FROM mysql.user;

-- Sprawdzenie własnych uprawnień
SHOW GRANTS;

```

---

## Część 2: Tworzenie użytkowników (20 minut)

### Podstawowa składnia CREATE USER

```

CREATE USER 'nazwa_użytkownika'@'host' IDENTIFIED BY 'hasło';

```

### Przykłady tworzenia użytkowników

```

-- Użytkownik z dostępem tylko z localhost
CREATE USER 'pracownik'@'localhost' IDENTIFIED BY 'BezpieczneHaslo123!';

-- Użytkownik z dostępem z dowolnego hosta
CREATE USER 'zdalny_admin'@'%' IDENTIFIED BY 'SuperHaslo456!';

-- Użytkownik z dostępem z konkretnego IP
CREATE USER 'klient_app'@'192.168.1.100' IDENTIFIED BY 'AppPassword789!';

-- Użytkownik z dostępem z konkretnej podsieci
CREATE USER 'serwer_web'@'192.168.1.%' IDENTIFIED BY 'WebHaslo000!';

```

### Specyfikacja hosta
- `localhost` – tylko lokalne połączenie
- `%` – dowolny host (wildcard)
- `192.168.1.100` – konkretny adres IP
- `192.168.1.%` – zakres adresów IP
- `example.com` – konkretna nazwa hosta

### Tworzenie użytkownika bez hasła (niezalecane)

```

-- Użytkownik testowy bez hasła
CREATE USER 'test_user'@'localhost';

```

### Sprawdzenie utworzonych użytkowników

```

-- Wyświetlenie wszystkich użytkowników
SELECT user, host, account_locked, password_expired
FROM mysql.user
ORDER BY user;

-- Sprawdzenie konkretnego użytkownika
SELECT user, host FROM mysql.user WHERE user = 'pracownik';

```

### Wymagania dotyczące haseł w MySQL

```

-- Sprawdzenie polityki haseł
SHOW VARIABLES LIKE 'validate_password%';

-- Przykład silnego hasła spełniającego wymagania:
-- - Minimum 8 znaków
-- - Wielkie i małe litery
-- - Cyfry i znaki specjalne
CREATE USER 'bezpieczny_user'@'localhost' IDENTIFIED BY 'Abc123!@\#';

```

---

## Część 3: Nadawanie uprawnień (GRANT) (25 minut)

### Podstawowa składnia GRANT

```

GRANT uprawnienie ON baza.tabela TO 'użytkownik'@'host';

```

### Typy uprawnień w MySQL

| Uprawnienie | Opis | Przykład użycia |
|-------------|------|----------------|
| `SELECT` | Odczyt danych | Raporty, zapytania |
| `INSERT` | Dodawanie rekordów | Formularze, aplikacje |
| `UPDATE` | Modyfikacja danych | Edycja rekordów |
| `DELETE` | Usuwanie rekordów | Administracja danymi |
| `CREATE` | Tworzenie tabel/baz | Deweloperzy |
| `DROP` | Usuwanie tabel/baz | Administratorzy |
| `ALTER` | Modyfikacja struktury | Migracje bazy |
| `INDEX` | Zarządzanie indeksami | Optymalizacja |
| `ALL PRIVILEGES` | Wszystkie uprawnienia | Pełny administrator |

### Przykłady nadawania uprawnień

#### Uprawnienia na poziomie tabeli

```

-- Podstawowe uprawnienia do odczytu
GRANT SELECT ON sklep.klienci TO 'pracownik'@'localhost';

-- Uprawnienia do dodawania i modyfikacji
GRANT INSERT, UPDATE ON sklep.produkty TO 'pracownik'@'localhost';

-- Pełne uprawnienia do konkretnej tabeli
GRANT ALL PRIVILEGES ON sklep.zamowienia TO 'manager'@'localhost';

```

#### Uprawnienia na poziomie bazy danych

```

-- Wszystkie uprawnienia do konkretnej bazy
GRANT ALL PRIVILEGES ON sklep.* TO 'admin_sklepu'@'localhost';

-- Tylko odczyt z całej bazy
GRANT SELECT ON sklep.* TO 'analityk'@'%';

-- Uprawnienia do modyfikacji struktury
GRANT CREATE, ALTER, DROP ON sklep.* TO 'developer'@'localhost';

```

#### Uprawnienia globalne (na wszystkie bazy)

```

-- Pełne uprawnienia administratora
GRANT ALL PRIVILEGES ON *.* TO 'super_admin'@'localhost';

-- Uprawnienia do tworzenia użytkowników
GRANT CREATE USER ON *.* TO 'hr_manager'@'localhost';

-- Uprawnienia systemowe
GRANT PROCESS, SHOW DATABASES ON *.* TO 'monitor'@'localhost';

```

#### Uprawnienia na poziomie kolumn

```

-- Dostęp tylko do wybranych kolumn
GRANT SELECT (imie, nazwisko), UPDATE (email)
ON sklep.klienci TO 'obsługa'@'localhost';

```

#### GRANT z opcją WITH GRANT OPTION

```

-- Użytkownik może nadawać uprawnienia innym
GRANT SELECT, INSERT ON sklep.* TO 'team_leader'@'localhost'
WITH GRANT OPTION;

```

### Uprawnienia do procedur składowanych

```

-- Uprawnienia do wykonywania procedur
GRANT EXECUTE ON PROCEDURE sklep.oblicz_rabat TO 'kasjer'@'localhost';

-- Tworzenie procedur
GRANT CREATE ROUTINE ON sklep.* TO 'developer'@'localhost';

```

### Sprawdzanie nadanych uprawnień

```

-- Uprawnienia konkretnego użytkownika
SHOW GRANTS FOR 'pracownik'@'localhost';

-- Własne uprawnienia
SHOW GRANTS;

-- Uprawnienia w czytelnej formie
SELECT * FROM information_schema.user_privileges
WHERE grantee = "'pracownik'@'localhost'";

```

### Praktyczne scenariusze uprawnień

```

-- Scenariusz 1: Analityk danych
CREATE USER 'analityk'@'%' IDENTIFIED BY 'Analiza123!';
GRANT SELECT ON sklep.* TO 'analityk'@'%';
GRANT SELECT ON mysql.* TO 'analityk'@'%'; -- metadata

-- Scenariusz 2: Operator aplikacji webowej
CREATE USER 'webapp'@'192.168.1.%' IDENTIFIED BY 'WebApp456!';
GRANT SELECT, INSERT, UPDATE, DELETE ON sklep.klienci TO 'webapp'@'192.168.1.%';
GRANT SELECT, INSERT, UPDATE ON sklep.zamowienia TO 'webapp'@'192.168.1.%';

-- Scenariusz 3: Administrator bazy danych
CREATE USER 'dba'@'localhost' IDENTIFIED BY 'DBA_Pass789!';
GRANT ALL PRIVILEGES ON *.* TO 'dba'@'localhost' WITH GRANT OPTION;

```

---

## Część 4: Odbieranie uprawnień (REVOKE) (15 minut)

### Podstawowa składnia REVOKE

```

REVOKE uprawnienie ON baza.tabela FROM 'użytkownik'@'host';

```

### Przykłady odbierania uprawnień

```

-- Odbieranie konkretnego uprawnienia
REVOKE DELETE ON sklep.klienci FROM 'pracownik'@'localhost';

-- Odbieranie wielu uprawnień
REVOKE INSERT, UPDATE ON sklep.produkty FROM 'pracownik'@'localhost';

-- Odbieranie wszystkich uprawnień do tabeli
REVOKE ALL PRIVILEGES ON sklep.zamowienia FROM 'manager'@'localhost';

-- Odbieranie uprawnień do całej bazy
REVOKE ALL PRIVILEGES ON sklep.* FROM 'admin_sklepu'@'localhost';

```

### REVOKE z GRANT OPTION

```

-- Odbieranie możliwości nadawania uprawnień
REVOKE GRANT OPTION ON sklep.* FROM 'team_leader'@'localhost';

-- Odbieranie uprawnienia wraz z GRANT OPTION
REVOKE ALL PRIVILEGES, GRANT OPTION ON sklep.* FROM 'team_leader'@'localhost';

```

### Sprawdzenie efektów REVOKE

```

-- Przed REVOKE
SHOW GRANTS FOR 'pracownik'@'localhost';

-- Wykonanie REVOKE
REVOKE UPDATE ON sklep.klienci FROM 'pracownik'@'localhost';

-- Po REVOKE
SHOW GRANTS FOR 'pracownik'@'localhost';

```

### Praktyczne przykłady zarządzania uprawnieniami

```

-- Przykład: Zmiana uprawnień pracownika
-- Krok 1: Sprawdzenie obecnych uprawnień
SHOW GRANTS FOR 'pracownik'@'localhost';

-- Krok 2: Odbieranie niepotrzebnych uprawnień
REVOKE DELETE ON sklep.* FROM 'pracownik'@'localhost';

-- Krok 3: Dodanie nowych uprawnień
GRANT SELECT ON sklep.raporty TO 'pracownik'@'localhost';

-- Krok 4: Weryfikacja zmian
SHOW GRANTS FOR 'pracownik'@'localhost';

```

---

## Część 5: Zarządzanie hasłami i usuwanie użytkowników (15 minut)

### Zmiana hasła użytkownika

```

-- Zmiana hasła przez administratora
SET PASSWORD FOR 'pracownik'@'localhost' = 'NoweHaslo123!';

-- Alternatywna składnia (MySQL 5.7.6+)
ALTER USER 'pracownik'@'localhost' IDENTIFIED BY 'NoweHaslo456!';

-- Zmiana własnego hasła
SET PASSWORD = 'MojeNoweHaslo789!';

```

### Wygasanie haseł

```

-- Ustawienie wygasania hasła
ALTER USER 'pracownik'@'localhost' PASSWORD EXPIRE;

-- Hasło wygasa po 90 dniach
ALTER USER 'pracownik'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;

-- Hasło nigdy nie wygasa
ALTER USER 'pracownik'@'localhost' PASSWORD EXPIRE NEVER;

```

### Blokowanie i odblokowanie użytkowników

```

-- Zablokowanie konta użytkownika
ALTER USER 'pracownik'@'localhost' ACCOUNT LOCK;

-- Odblokowanie konta użytkownika
ALTER USER 'pracownik'@'localhost' ACCOUNT UNLOCK;

-- Sprawdzenie statusu konta
SELECT user, host, account_locked FROM mysql.user
WHERE user = 'pracownik';

```

### Usuwanie użytkowników

```

-- Usunięcie użytkownika
DROP USER 'stary_pracownik'@'localhost';

-- Usunięcie wielu użytkowników jednocześnie
DROP USER 'user1'@'localhost', 'user2'@'%', 'user3'@'192.168.1.100';

-- Bezpieczne usuwanie (sprawdzenie przed usunięciem)
SELECT user, host FROM mysql.user WHERE user = 'do_usuniecia';
DROP USER IF EXISTS 'do_usuniecia'@'localhost';

```

### Kopiowanie uprawnień między użytkownikami

```

-- Skopiowanie uprawnień (pośrednio przez SHOW GRANTS)
SHOW GRANTS FOR 'wzorzec_user'@'localhost';
-- Następnie ręcznie nadanie tych samych uprawnień nowemu użytkownikowi

-- Przykład kopiowania uprawnień
CREATE USER 'nowy_pracownik'@'localhost' IDENTIFIED BY 'Haslo123!';
GRANT SELECT, INSERT ON sklep.klienci TO 'nowy_pracownik'@'localhost';
GRANT SELECT ON sklep.produkty TO 'nowy_pracownik'@'localhost';

```

---

## Część 6: Praktyczne ćwiczenia i najlepsze praktyki (5 minut)

### Kompleksowe ćwiczenie - sklep internetowy

```

-- 1. Tworzenie różnych typów użytkowników
CREATE USER 'manager_sprzedazy'@'localhost' IDENTIFIED BY 'Manager123!';
CREATE USER 'operator_magazynu'@'localhost' IDENTIFIED BY 'Magazyn456!';
CREATE USER 'księgowa'@'localhost' IDENTIFIED BY 'Ksiegi789!';
CREATE USER 'aplikacja_web'@'192.168.1.%' IDENTIFIED BY 'WebApp000!';

-- 2. Nadawanie uprawnień zgodnie z rolami
-- Manager sprzedaży - dostęp do klientów i zamówień
GRANT SELECT, INSERT, UPDATE ON sklep.klienci TO 'manager_sprzedazy'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON sklep.zamowienia TO 'manager_sprzedazy'@'localhost';

-- Operator magazynu - tylko produkty
GRANT SELECT, UPDATE ON sklep.produkty TO 'operator_magazynu'@'localhost';

-- Księgowa - dostęp do raportów finansowych
GRANT SELECT ON sklep.* TO 'księgowa'@'localhost';

-- Aplikacja web - ograniczone uprawnienia
GRANT SELECT, INSERT ON sklep.klienci TO 'aplikacja_web'@'192.168.1.%';
GRANT SELECT, INSERT ON sklep.zamowienia TO 'aplikacja_web'@'192.168.1.%';

-- 3. Sprawdzenie uprawnień
SHOW GRANTS FOR 'manager_sprzedazy'@'localhost';
SHOW GRANTS FOR 'aplikacja_web'@'192.168.1.%';

```

### Najlepsze praktyki bezpieczeństwa

#### 1. Zasada najmniejszych uprawnień
```

-- ŹLE: Nadmierne uprawnienia
GRANT ALL PRIVILEGES ON *.* TO 'pracownik'@'%';

-- DOBRZE: Minimalne niezbędne uprawnienia
GRANT SELECT ON sklep.produkty TO 'pracownik'@'localhost';

```

#### 2. Ograniczanie dostępu po hostach
```

-- ŹLE: Dostęp z dowolnego miejsca
CREATE USER 'admin'@'%' IDENTIFIED BY 'hasło';

-- DOBRZE: Ograniczony dostęp
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'hasło';
CREATE USER 'app'@'192.168.1.%' IDENTIFIED BY 'hasło';

```

#### 3. Regularne sprawdzanie uprawnień
```

-- Audyt wszystkich użytkowników
SELECT user, host, account_locked, password_expired
FROM mysql.user
ORDER BY user;

-- Znajdź użytkowników z uprawnieniami globalnymi
SELECT grantee, privilege_type
FROM information_schema.user_privileges
WHERE is_grantable = 'YES';

```

### Typowe błędy i jak ich unikać

#### 1. Zapomnienie o FLUSH PRIVILEGES (w starszych wersjach)
```

-- W nowszych wersjach MySQL GRANT/REVOKE automatycznie odświeża uprawnienia
-- Ale w starszych wersjach może być potrzebne:
FLUSH PRIVILEGES;

```

#### 2. Niespecyfikowanie hosta
```

-- ŹLE: Może utworzyć niechciane kombinacje
CREATE USER 'test';

-- DOBRZE: Zawsze określ host
CREATE USER 'test'@'localhost';

```

#### 3. Zbyt słabe hasła
```

-- ŹLE: Słabe hasło
CREATE USER 'user'@'localhost' IDENTIFIED BY '123';

-- DOBRZE: Silne hasło
CREATE USER 'user'@'localhost' IDENTIFIED BY 'Secure123!@\#';

```

### Przydatne zapytania diagnostyczne

```

-- Lista wszystkich uprawnień wszystkich użytkowników
SELECT
grantee,
table_schema,
privilege_type
FROM information_schema.schema_privileges
ORDER BY grantee, table_schema;

-- Użytkownicy z uprawnieniami do konkretnej bazy
SELECT grantee, privilege_type
FROM information_schema.schema_privileges
WHERE table_schema = 'sklep';

-- Sprawdzenie aktywnych połączeń
SELECT user, host, db, command, time
FROM information_schema.processlist
WHERE user != 'system user';

```

### Zadania do samodzielnego wykonania

1. Utwórz użytkownika 'raportowicz' z dostępem tylko do odczytu z bazy 'sklep'
2. Nadaj użytkownikowi 'webmaster' uprawnienia do modyfikacji tabeli 'produkty'
3. Odbierz uprawnienie DELETE użytkownikowi 'operator'
4. Zmień hasło użytkownika 'admin' na nowe, bezpieczne
5. Usuń nieaktywnego użytkownika 'stary_kont'

**Koniec lekcji**
```

