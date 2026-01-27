11. Dostęp do bazy danych z poziomu języka PHP – połączenie z bazą, pobieranie danych,

# Lekcja: Dostęp do bazy danych z poziomu języka PHP – połączenie z bazą, pobieranie danych, wprowadzanie danych i modyfikacja danych

---

## Struktura lekcji (90 minut)
1. **Wprowadzenie do PHP i MySQL** (10 min)
2. **Połączenie z bazą danych** (20 min)
3. **Pobieranie danych (SELECT)** (25 min)
4. **Wprowadzanie danych (INSERT)** (15 min)
5. **Modyfikacja i usuwanie danych (UPDATE, DELETE)** (15 min)
6. **Praktyczne ćwiczenia i obsługa błędów** (5 min)

---

## Część 1: Wprowadzenie do PHP i MySQL (10 minut)

### Dlaczego PHP i MySQL?
- **PHP** – najpopularniejszy język skryptowy do aplikacji webowych
- **MySQL** – jedna z najczęściej używanych baz danych
- **Integracja** – doskonała współpraca między PHP a MySQL
- **XAMPP** – środowisko deweloperskie łączące Apache, PHP i MySQL

### Rozszerzenia PHP do obsługi MySQL
- **MySQLi** – MySQL Improved (zalecane)
- **PDO** – PHP Data Objects (uniwersalne)
- **MySQL** – przestarzałe (nie używać)

### Przygotowanie środowiska testowego

```

-- Stworzenie bazy danych testowej
CREATE DATABASE php_mysql_test;
USE php_mysql_test;

-- Tabela użytkowników
CREATE TABLE uzytkownicy (
id INT PRIMARY KEY AUTO_INCREMENT,
imie VARCHAR(50),
nazwisko VARCHAR(50),
email VARCHAR(100) UNIQUE,
wiek INT,
data_rejestracji DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela produktów
CREATE TABLE produkty (
id INT PRIMARY KEY AUTO_INCREMENT,
nazwa VARCHAR(200),
cena DECIMAL(10,2),
kategoria VARCHAR(50),
dostepny BOOLEAN DEFAULT TRUE
);

-- Przykładowe dane
INSERT INTO uzytkownicy (imie, nazwisko, email, wiek) VALUES
('Jan', 'Kowalski', 'jan@test.pl', 30),
('Anna', 'Nowak', 'anna@test.pl', 25),
('Piotr', 'Wiśniewski', 'piotr@test.pl', 35);

INSERT INTO produkty (nazwa, cena, kategoria) VALUES
('Laptop', 2999.99, 'Elektronika'),
('Mysz', 49.99, 'Akcesoria'),
('Monitor', 899.99, 'Elektronika');

```

---

## Część 2: Połączenie z bazą danych (20 minut)

### Podstawowe połączenie MySQLi (obiektowe)

```

<?php
// Parametry połączenia
$host = "localhost";
$username = "root";
$password = "";  // domyślnie puste w XAMPP
$database = "php_mysql_test";

// Utworzenie połączenia
$conn = new mysqli($host, $username, $password, $database);

// Sprawdzenie połączenia
if ($conn->connect_error) {
    die("Błąd połączenia: " . $conn->connect_error);
}

echo "Połączenie udane!";
?>
```

### Połączenie MySQLi (proceduralne)

```

<?php
$host = "localhost";
$username = "root";
$password = "";
$database = "php_mysql_test";

// Utworzenie połączenia proceduralnego
$conn = mysqli_connect($host, $username, $password, $database);

// Sprawdzenie połączenia
if (!$conn) {
    die("Błąd połączenia: " . mysqli_connect_error());
}

echo "Połączenie udane!";
?>
```

### Ustawienie kodowania znaków

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// Ustawienie kodowania UTF-8
$conn->set_charset("utf8");

// Alternatywnie proceduralnie
// mysqli_set_charset($conn, "utf8");
?>
```

### Bezpieczne przechowywanie danych połączenia

**config.php:**
```

<?php
// Konfiguracja bazy danych
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'php_mysql_test');

// Funkcja połączenia
function connectDB() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    if ($conn->connect_error) {
        die("Błąd połączenia: " . $conn->connect_error);
    }
    
    $conn->set_charset("utf8");
    return $conn;
}
?>
```

### Zamykanie połączenia

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// Tu wykonujemy operacje na bazie...

// Zamknięcie połączenia
$conn->close();

// Proceduralnie: mysqli_close($conn);
?>
```

---

## Część 3: Pobieranie danych (SELECT) (25 minut)

### Podstawowe pobieranie danych

```

<?php
include 'config.php';
$conn = connectDB();

// Zapytanie SELECT
$sql = "SELECT id, imie, nazwisko, email FROM uzytkownicy";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Pobieranie wierszy
    while($row = $result->fetch_assoc()) {
        echo "ID: " . $row["id"]. " - Imię: " . $row["imie"]. 
             " " . $row["nazwisko"]. " - Email: " . $row["email"]. "<br>";
    }
} else {
    echo "Brak wyników";
}

$conn->close();
?>
```

### Różne metody pobierania danych

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");
$sql = "SELECT * FROM uzytkownicy";
$result = $conn->query($sql);

// Metoda 1: fetch_assoc() - tablica asocjacyjna
while($row = $result->fetch_assoc()) {
    echo $row['imie'] . " " . $row['nazwisko'] . "<br>";
}

// Metoda 2: fetch_array() - tablica numerowana i asocjacyjna
$result->data_seek(0); // Reset wskaźnika
while($row = $result->fetch_array()) {
    echo $row . " " . $row['nazwisko'] . "<br>"; // można używać indeksów i nazw[^9]
}

// Metoda 3: fetch_row() - tylko tablica numerowana
$result->data_seek(0);
while($row = $result->fetch_row()) {
    echo $row . " " . $row . "<br>"; // tylko indeksy numeryczne[^1][^9]
}

// Metoda 4: fetch_object() - obiekt
$result->data_seek(0);
while($row = $result->fetch_object()) {
    echo $row->imie . " " . $row->nazwisko . "<br>";
}
?>
```

### Zapytania z warunkami WHERE

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// Przykład 1: Konkretny warunek
$wiek_min = 30;
$sql = "SELECT * FROM uzytkownicy WHERE wiek >= $wiek_min";
$result = $conn->query($sql);

while($row = $result->fetch_assoc()) {
    echo $row['imie'] . " (" . $row['wiek'] . " lat)<br>";
}

// Przykład 2: LIKE i wzorce
$szukane_imie = "Jan";
$sql = "SELECT * FROM uzytkownicy WHERE imie LIKE '%$szukane_imie%'";
$result = $conn->query($sql);

// Przykład 3: Wiele warunków
$sql = "SELECT * FROM produkty WHERE cena BETWEEN 100 AND 1000 AND kategoria = 'Elektronika'";
$result = $conn->query($sql);
?>
```

### Sortowanie i ograniczanie wyników

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// Sortowanie
$sql = "SELECT * FROM uzytkownicy ORDER BY nazwisko ASC, imie ASC";
$result = $conn->query($sql);

// Ograniczenie wyników (LIMIT)
$sql = "SELECT * FROM produkty ORDER BY cena DESC LIMIT 5";
$result = $conn->query($sql);

// LIMIT z OFFSET (stronicowanie)
$strona = 1;
$na_stronie = 2;
$offset = ($strona - 1) * $na_stronie;
$sql = "SELECT * FROM uzytkownicy LIMIT $offset, $na_stronie";
$result = $conn->query($sql);
?>
```

### Funkcje agregujące w PHP

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// Liczenie rekordów
$sql = "SELECT COUNT(*) as liczba_uzytkownikow FROM uzytkownicy";
$result = $conn->query($sql);
$row = $result->fetch_assoc();
echo "Liczba użytkowników: " . $row['liczba_uzytkownikow'];

// Średnia, suma, min, max
$sql = "SELECT AVG(cena) as srednia, SUM(cena) as suma, MIN(cena) as min, MAX(cena) as max FROM produkty";
$result = $conn->query($sql);
$row = $result->fetch_assoc();
echo "Średnia cena: " . round($row['srednia'], 2) . " PLN<br>";
echo "Suma wartości: " . $row['suma'] . " PLN<br>";
?>
```

---

## Część 4: Wprowadzanie danych (INSERT) (15 minut)

### Podstawowe wstawianie danych

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// INSERT pojedynczego rekordu
$imie = "Maria";
$nazwisko = "Kowalczyk";
$email = "maria@test.pl";
$wiek = 28;

$sql = "INSERT INTO uzytkownicy (imie, nazwisko, email, wiek) 
        VALUES ('$imie', '$nazwisko', '$email', $wiek)";

if ($conn->query($sql) === TRUE) {
    echo "Nowy użytkownik został dodany. ID: " . $conn->insert_id;
} else {
    echo "Błąd: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
```

### Bezpieczne wstawianie z Prepared Statements

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// Prepared statement zapobiega SQL injection
$stmt = $conn->prepare("INSERT INTO uzytkownicy (imie, nazwisko, email, wiek) VALUES (?, ?, ?, ?)");
$stmt->bind_param("sssi", $imie, $nazwisko, $email, $wiek);

// Dane do wstawienia
$imie = "Tomasz";
$nazwisko = "Nowicki";
$email = "tomasz@test.pl";
$wiek = 33;

if ($stmt->execute()) {
    echo "Użytkownik dodany. ID: " . $conn->insert_id;
} else {
    echo "Błąd: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
```

### Wstawianie danych z formularza HTML

**formularz.html:**
```

<!DOCTYPE html>

<html>
<head>
    <title>Dodaj użytkownika</title>
    <meta charset="UTF-8">
</head>
<body>
    <form action="dodaj_uzytkownika.php" method="POST">
        <label>Imię:</label>
        <input type="text" name="imie" required><br><br>
        
        <label>Nazwisko:</label>
        <input type="text" name="nazwisko" required><br><br>
        
        <label>Email:</label>
        <input type="email" name="email" required><br><br>
        
        <label>Wiek:</label>
        <input type="number" name="wiek" min="1" max="120" required><br><br>
        
        <input type="submit" value="Dodaj użytkownika">
    </form>
</body>
</html>
```

**dodaj_uzytkownika.php:**
```

<?php
if ($_POST) {
    $conn = new mysqli("localhost", "root", "", "php_mysql_test");
    
    // Sanityzacja danych
    $imie = $conn->real_escape_string($_POST['imie']);
    $nazwisko = $conn->real_escape_string($_POST['nazwisko']);
    $email = $conn->real_escape_string($_POST['email']);
    $wiek = (int)$_POST['wiek'];
    
    // Prepared statement
    $stmt = $conn->prepare("INSERT INTO uzytkownicy (imie, nazwisko, email, wiek) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("sssi", $imie, $nazwisko, $email, $wiek);
    
    if ($stmt->execute()) {
        echo "Użytkownik został dodany pomyślnie!";
        echo "<br><a href='formularz.html'>Dodaj kolejnego</a>";
    } else {
        echo "Błąd podczas dodawania: " . $stmt->error;
    }
    
    $stmt->close();
    $conn->close();
}
?>
```

---

## Część 5: Modyfikacja i usuwanie danych (UPDATE, DELETE) (15 minut)

### Aktualizacja danych (UPDATE)

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// UPDATE podstawowy
$nowy_email = "jan.kowalski@nowy-email.pl";
$user_id = 1;

$sql = "UPDATE uzytkownicy SET email = '$nowy_email' WHERE id = $user_id";

if ($conn->query($sql) === TRUE) {
    echo "Email został zaktualizowany. Zmodyfikowano wierszy: " . $conn->affected_rows;
} else {
    echo "Błąd podczas aktualizacji: " . $conn->error;
}

// UPDATE z prepared statement (bezpieczniejszy)
$stmt = $conn->prepare("UPDATE uzytkownicy SET email = ?, wiek = ? WHERE id = ?");
$stmt->bind_param("sii", $email, $wiek, $id);

$email = "anna.nowak@updated.pl";
$wiek = 26;
$id = 2;

if ($stmt->execute()) {
    echo "Dane zaktualizowane. Zmodyfikowano wierszy: " . $stmt->affected_rows;
} else {
    echo "Błąd: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
```

### Usuwanie danych (DELETE)

```

<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");

// DELETE pojedynczego rekordu
$user_id = 3;
$sql = "DELETE FROM uzytkownicy WHERE id = $user_id";

if ($conn->query($sql) === TRUE) {
    if ($conn->affected_rows > 0) {
        echo "Użytkownik został usunięty. Usunięto wierszy: " . $conn->affected_rows;
    } else {
        echo "Nie znaleziono użytkownika o podanym ID";
    }
} else {
    echo "Błąd podczas usuwania: " . $conn->error;
}

// DELETE z warunkiem (bezpieczny)
$stmt = $conn->prepare("DELETE FROM uzytkownicy WHERE email = ?");
$stmt->bind_param("s", $email);

$email = "test@delete.pl";

if ($stmt->execute()) {
    echo "Usunięto użytkowników: " . $stmt->affected_rows;
} else {
    echo "Błąd: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
```

### Kompleksowy przykład CRUD

```

<?php
class UserManager {
    private $conn;
    
    public function __construct() {
        $this->conn = new mysqli("localhost", "root", "", "php_mysql_test");
        if ($this->conn->connect_error) {
            die("Błąd połączenia: " . $this->conn->connect_error);
        }
        $this->conn->set_charset("utf8");
    }
    
    // CREATE - Dodawanie użytkownika
    public function addUser($imie, $nazwisko, $email, $wiek) {
        $stmt = $this->conn->prepare("INSERT INTO uzytkownicy (imie, nazwisko, email, wiek) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("sssi", $imie, $nazwisko, $email, $wiek);
        
        if ($stmt->execute()) {
            return $this->conn->insert_id;
        }
        return false;
    }
    
    // READ - Pobieranie użytkowników
    public function getUsers() {
        $sql = "SELECT * FROM uzytkownicy ORDER BY nazwisko";
        $result = $this->conn->query($sql);
        return $result->fetch_all(MYSQLI_ASSOC);
    }
    
    // UPDATE - Aktualizacja użytkownika
    public function updateUser($id, $imie, $nazwisko, $email, $wiek) {
        $stmt = $this->conn->prepare("UPDATE uzytkownicy SET imie=?, nazwisko=?, email=?, wiek=? WHERE id=?");
        $stmt->bind_param("sssii", $imie, $nazwisko, $email, $wiek, $id);
        return $stmt->execute();
    }
    
    // DELETE - Usuwanie użytkownika
    public function deleteUser($id) {
        $stmt = $this->conn->prepare("DELETE FROM uzytkownicy WHERE id=?");
        $stmt->bind_param("i", $id);
        return $stmt->execute();
    }
    
    public function __destruct() {
        $this->conn->close();
    }
}

// Użycie klasy
$userManager = new UserManager();

// Dodanie użytkownika
$newId = $userManager->addUser("Test", "User", "test@user.pl", 25);
echo "Dodano użytkownika o ID: $newId<br>";

// Pobranie wszystkich użytkowników
$users = $userManager->getUsers();
foreach ($users as $user) {
    echo $user['imie'] . " " . $user['nazwisko'] . " - " . $user['email'] . "<br>";
}
?>
```

---

## Część 6: Praktyczne ćwiczenia i obsługa błędów (5 minut)

### Obsługa błędów i wyjątków

```

<?php
// Włączenie raportowania błędów MySQLi
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

try {
    $conn = new mysqli("localhost", "root", "", "php_mysql_test");
    $conn->set_charset("utf8");
    
    // Operacje na bazie danych...
    $sql = "SELECT * FROM nieistniejaca_tabela"; // To wywoła błąd
    $result = $conn->query($sql);
    
} catch (mysqli_sql_exception $e) {
    echo "Błąd SQL: " . $e->getMessage();
} catch (Exception $e) {
    echo "Ogólny błąd: " . $e->getMessage();
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}
?>
```

### Walidacja i sanityzacja danych

```

<?php
function validateAndSanitize($data, $type) {
    switch ($type) {
        case 'email':
            $data = filter_var($data, FILTER_SANITIZE_EMAIL);
            return filter_var($data, FILTER_VALIDATE_EMAIL) ? $data : false;
            
        case 'int':
            return filter_var($data, FILTER_VALIDATE_INT);
            
        case 'string':
            return htmlspecialchars(strip_tags(trim($data)));
            
        default:
            return false;
    }
}

// Przykład użycia
if ($_POST) {
    $imie = validateAndSanitize($_POST['imie'], 'string');
    $email = validateAndSanitize($_POST['email'], 'email');
    $wiek = validateAndSanitize($_POST['wiek'], 'int');
    
    if ($imie && $email && $wiek) {
        // Dane są prawidłowe, można zapisać do bazy
    } else {
        echo "Nieprawidłowe dane wejściowe!";
    }
}
?>
```

### Kompleksny przykład aplikacji

```

<?php
session_start();
?>
<!DOCTYPE html>

<html>
<head>
    <title>System użytkowników</title>
    <meta charset="UTF-8">
</head>
<body>
    <h2>Lista użytkowników</h2>
    
    <?php
    $conn = new mysqli("localhost", "root", "", "php_mysql_test");
    
    // Obsługa dodawania nowego użytkownika
    if ($_POST && isset($_POST['add_user'])) {
        $stmt = $conn->prepare("INSERT INTO uzytkownicy (imie, nazwisko, email, wiek) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("sssi", $_POST['imie'], $_POST['nazwisko'], $_POST['email'], $_POST['wiek']);
        
        if ($stmt->execute()) {
            echo "<p style='color: green;'>Użytkownik został dodany!</p>";
        } else {
            echo "<p style='color: red;'>Błąd: " . $stmt->error . "</p>";
        }
        $stmt->close();
    }
    
    // Wyświetlenie wszystkich użytkowników
    $result = $conn->query("SELECT * FROM uzytkownicy ORDER BY id");
    
    if ($result->num_rows > 0) {
        echo "<table border='1'>";
        echo "<tr><th>ID</th><th>Imię</th><th>Nazwisko</th><th>Email</th><th>Wiek</th></tr>";
        
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>" . $row['id'] . "</td>";
            echo "<td>" . $row['imie'] . "</td>";
            echo "<td>" . $row['nazwisko'] . "</td>";
            echo "<td>" . $row['email'] . "</td>";
            echo "<td>" . $row['wiek'] . "</td>";
            echo "</tr>";
        }
        echo "</table>";
    } else {
        echo "<p>Brak użytkowników w bazie danych.</p>";
    }
    
    $conn->close();
    ?>
    
    <h3>Dodaj nowego użytkownika</h3>
    <form method="POST">
        <input type="text" name="imie" placeholder="Imię" required><br><br>
        <input type="text" name="nazwisko" placeholder="Nazwisko" required><br><br>
        <input type="email" name="email" placeholder="Email" required><br><br>
        <input type="number" name="wiek" placeholder="Wiek" min="1" max="120" required><br><br>
        <input type="submit" name="add_user" value="Dodaj użytkownika">
    </form>
</body>
</html>
```

### Najlepsze praktyki i wskazówki na egzamin INF.03

1. **Zawsze używaj prepared statements** dla danych od użytkownika
2. **Sprawdzaj połączenie z bazą** przed wykonaniem operacji
3. **Zamykaj połączenia** po zakończeniu pracy
4. **Waliduj i sanityzuj dane** wejściowe
5. **Obsługuj błędy** w sposób przyjazny użytkownikowi
6. **Używaj odpowiedniego kodowania** (UTF-8)

### Zadania do samodzielnego wykonania

1. Stwórz formularz edycji użytkownika
2. Dodaj funkcjonalność wyszukiwania użytkowników
3. Zaimplementuj stronicowanie listy użytkowników
4. Stwórz system logowania i sesji
5. Dodaj walidację unikalności email

**Koniec lekcji**
```
