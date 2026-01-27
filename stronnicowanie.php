<?php
$conn = new mysqli("localhost", "root", "", "php_mysql_test");
if ($conn->connect_error) {
    die("Błąd połączenia: " . $conn->connect_error);
}
echo "Połączono z bazą: " . $conn->host_info . "<br>";

// Sprawdź tabele
$tables = $conn->query("SHOW TABLES");
echo "<h3>Tabele w bazie:</h3>";
while ($row = $tables->fetch_array()) {
    echo "- " . $row[0] . "<br>";
}

// Sortowanie
echo "<h3>Sortowanie uzytkownicy:</h3>";
$sql = "SELECT * FROM uzytkownicy ORDER BY nazwisko ASC, imie ASC";
$result = $conn->query($sql);
if (!$result) {
    echo "Błąd: " . $conn->error . "<br>";
} else {
    echo "Znalezione wiersze: " . $result->num_rows . "<br>";
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            echo "Imię: " . $row['imie'] ?? 'brak' . ", Nazwisko: " . $row['nazwisko'] ?? 'brak' . "<br>";
        }
    } else {
        echo "Brak danych w tabeli uzytkownicy<br>";
    }
    $result->free();
}

// Ograniczenie wyników (LIMIT)
echo "<h3>Najdroższe produkty:</h3>";
$sql = "SELECT * FROM produkty ORDER BY cena DESC LIMIT 5";
$result = $conn->query($sql);
if (!$result) {
    echo "Błąd: " . $conn->error . "<br>";
} else {
    echo "Znalezione wiersze: " . $result->num_rows . "<br>";
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            echo "Produkt: " . $row['nazwa'] ?? 'brak' . ", Cena: " . $row['cena'] ?? 'brak' . "<br>";
        }
    } else {
        echo "Brak danych w tabeli produkty<br>";
    }
    $result->free();
}

// Stronicowanie
echo "<h3>Stronicowanie (strona 1):</h3>";
$strona = 1;
$na_stronie = 2;
$offset = ($strona - 1) * $na_stronie;
$sql = "SELECT * FROM uzytkownicy LIMIT $offset, $na_stronie";
$result = $conn->query($sql);
if (!$result) {
    echo "Błąd: " . $conn->error . "<br>";
} else {
    echo "Znalezione wiersze: " . $result->num_rows . "<br>";
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            echo "Imię: " . $row['imie'] ?? 'brak' . ", Nazwisko: " . $row['nazwisko'] ?? 'brak' . "<br>";
        }
    } else {
        echo "Brak danych na stronie 1<br>";
    }
    $result->free();
}

$conn->close();
?>
