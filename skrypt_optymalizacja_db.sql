DROP DATABASE IF EXISTS optymalizacja_demo;
CREATE DATABASE optymalizacja_demo;
USE optymalizacja_demo;

CREATE TABLE pracownicy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    departament VARCHAR(50),
    pensja DECIMAL(10,2),
    data_zatrudnienia DATE
);

-- Wstaw 10000 rekordów (demo z dużą ilością danych)
DELIMITER //
CREATE PROCEDURE WstawDane()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 10000 DO
        INSERT INTO pracownicy (imie, nazwisko, departament, pensja, data_zatrudnienia)
        VALUES (CONCAT('Imie', i), CONCAT('Nazwisko', i), CONCAT('Dept', MOD(i,10)+1), RAND()*10000+2000, DATE_SUB(NOW(), INTERVAL FLOOR(RAND()*3650) DAY));
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL WstawDane();
DROP PROCEDURE WstawDane;