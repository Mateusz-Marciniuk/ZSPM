-- ============================================================================
-- SKRYPT BAZY DANYCH DO ĆWICZEŃ - ARCHITEKTURA MySQL/InnoDB
-- Lekcja: Architektura bazy danych MySQL (silnik InnoDB)
-- Czas wykonania: ~5-10 minut
-- ============================================================================

-- Usunięcie istniejącej bazy danych (jeśli istnieje)
DROP DATABASE IF EXISTS innodb_lab;

-- Utworzenie nowej bazy danych
CREATE DATABASE innodb_lab 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE innodb_lab;

-- ============================================================================
-- SEKCJA 1: TABELA USERS - Do ćwiczeń SELECT i indeksów
-- ============================================================================

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    balance DECIMAL(10,2) DEFAULT 0.00,
    
    -- Indeksy
    UNIQUE KEY idx_email (email),
    INDEX idx_city (city),
    INDEX idx_status (status),
    INDEX idx_country_city (country, city),
    INDEX idx_registration_date (registration_date)
) ENGINE=InnoDB;

-- Procedura wypełniająca tabelę users testowymi danymi
DELIMITER $$

CREATE PROCEDURE fill_users(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_name VARCHAR(100);
    DECLARE random_email VARCHAR(150);
    DECLARE random_city VARCHAR(50);
    DECLARE random_country VARCHAR(50);
    DECLARE random_status VARCHAR(10);
    
    WHILE i <= num_rows DO
        SET random_name = CONCAT('User_', LPAD(i, 6, '0'));
        SET random_email = CONCAT('user', i, '@example.com');
        SET random_city = ELT(FLOOR(1 + RAND() * 10), 
            'Warszawa', 'Kraków', 'Wrocław', 'Poznań', 'Gdańsk',
            'Szczecin', 'Lublin', 'Katowice', 'Białystok', 'Gdynia');
        SET random_country = ELT(FLOOR(1 + RAND() * 5),
            'Poland', 'Germany', 'France', 'Spain', 'Italy');
        SET random_status = ELT(FLOOR(1 + RAND() * 3),
            'active', 'inactive', 'banned');
        
        INSERT INTO users (name, email, phone, city, country, status, balance, registration_date)
        VALUES (
            random_name,
            random_email,
            CONCAT('+48', LPAD(FLOOR(RAND() * 1000000000), 9, '0')),
            random_city,
            random_country,
            random_status,
            ROUND(RAND() * 10000, 2),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
        );
        
        SET i = i + 1;
        
        -- Commit co 1000 wierszy dla wydajności
        IF i % 1000 = 0 THEN
            COMMIT;
        END IF;
    END WHILE;
    
    COMMIT;
END$$

DELIMITER ;

-- Wypełnienie tabeli 100,000 użytkowników
-- UWAGA: To może zająć 1-2 minuty!
CALL fill_users(100000);

-- Weryfikacja
SELECT COUNT(*) AS total_users FROM users;
SELECT status, COUNT(*) AS count FROM users GROUP BY status;

-- ============================================================================
-- SEKCJA 2: TABELA PRODUCTS - Do ćwiczeń INSERT/UPDATE i MVCC
-- ============================================================================

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2),
    stock INT DEFAULT 0,
    supplier_id INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indeksy
    INDEX idx_category (category),
    INDEX idx_price (price),
    INDEX idx_stock (stock),
    INDEX idx_category_price (category, price),
    INDEX idx_supplier (supplier_id)
) ENGINE=InnoDB;

-- Procedura wypełniająca tabelę products
DELIMITER $$

CREATE PROCEDURE fill_products(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_category VARCHAR(50);
    DECLARE random_subcategory VARCHAR(50);
    DECLARE random_price DECIMAL(10,2);
    DECLARE random_cost DECIMAL(10,2);
    
    WHILE i <= num_rows DO
        SET random_category = ELT(FLOOR(1 + RAND() * 8),
            'Electronics', 'Clothing', 'Books', 'Food', 
            'Toys', 'Sports', 'Home', 'Garden');
        
        SET random_subcategory = ELT(FLOOR(1 + RAND() * 5),
            'Premium', 'Standard', 'Budget', 'Clearance', 'New');
        
        SET random_cost = ROUND(10 + RAND() * 990, 2);
        SET random_price = ROUND(random_cost * (1.2 + RAND() * 0.8), 2);
        
        INSERT INTO products (name, category, subcategory, price, cost, stock, supplier_id, description)
        VALUES (
            CONCAT(random_category, ' Item #', i),
            random_category,
            random_subcategory,
            random_price,
            random_cost,
            FLOOR(RAND() * 1000),
            FLOOR(1 + RAND() * 100),
            CONCAT('Description for product ', i, '. High quality item from our ', random_category, ' collection.')
        );
        
        SET i = i + 1;
        
        IF i % 1000 = 0 THEN
            COMMIT;
        END IF;
    END WHILE;
    
    COMMIT;
END$$

DELIMITER ;

-- Wypełnienie 100,000 produktów
CALL fill_products(100000);

-- Weryfikacja
SELECT COUNT(*) AS total_products FROM products;
SELECT category, COUNT(*) AS count, AVG(price) AS avg_price 
FROM products 
GROUP BY category;

-- ============================================================================
-- SEKCJA 3: TABELA ORDERS - Do ćwiczeń z JOIN i transakcjami
-- ============================================================================

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    payment_method ENUM('credit_card', 'paypal', 'bank_transfer', 'cash') DEFAULT 'credit_card',
    shipping_address TEXT,
    notes TEXT,
    
    -- Klucze obce
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indeksy
    INDEX idx_user_id (user_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (status),
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_per_unit DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    
    -- Klucze obce
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    
    -- Indeksy
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB;

-- Procedura generująca zamówienia
DELIMITER $$

CREATE PROCEDURE fill_orders(IN num_orders INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_user_id INT;
    DECLARE random_product_id INT;
    DECLARE random_quantity INT;
    DECLARE random_price DECIMAL(10,2);
    DECLARE order_total DECIMAL(10,2);
    DECLARE new_order_id INT;
    DECLARE items_in_order INT;
    DECLARE j INT;
    
    WHILE i <= num_orders DO
        -- Losowy użytkownik
        SET random_user_id = FLOOR(1 + RAND() * 100000);
        
        -- Losowa liczba produktów w zamówieniu (1-5)
        SET items_in_order = FLOOR(1 + RAND() * 5);
        SET order_total = 0;
        
        -- Tworzenie zamówienia
        INSERT INTO orders (user_id, total_amount, status, payment_method, order_date)
        VALUES (
            random_user_id,
            0, -- Zostanie zaktualizowane
            ELT(FLOOR(1 + RAND() * 5), 'pending', 'processing', 'shipped', 'delivered', 'cancelled'),
            ELT(FLOOR(1 + RAND() * 4), 'credit_card', 'paypal', 'bank_transfer', 'cash'),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 90) DAY)
        );
        
        SET new_order_id = LAST_INSERT_ID();
        
        -- Dodawanie pozycji zamówienia
        SET j = 1;
        WHILE j <= items_in_order DO
            SET random_product_id = FLOOR(1 + RAND() * 100000);
            SET random_quantity = FLOOR(1 + RAND() * 5);
            
            -- Pobieranie ceny produktu
            SELECT price INTO random_price FROM products WHERE id = random_product_id LIMIT 1;
            
            IF random_price IS NOT NULL THEN
                INSERT INTO order_items (order_id, product_id, quantity, price_per_unit, subtotal)
                VALUES (
                    new_order_id,
                    random_product_id,
                    random_quantity,
                    random_price,
                    random_price * random_quantity
                );
                
                SET order_total = order_total + (random_price * random_quantity);
            END IF;
            
            SET j = j + 1;
        END WHILE;
        
        -- Aktualizacja sumy zamówienia
        UPDATE orders SET total_amount = order_total WHERE id = new_order_id;
        
        SET i = i + 1;
        
        IF i % 100 = 0 THEN
            COMMIT;
        END IF;
    END WHILE;
    
    COMMIT;
END$$

DELIMITER ;

-- Wypełnienie 10,000 zamówień (mniej niż users/products dla realności)
CALL fill_orders(10000);

-- Weryfikacja
SELECT COUNT(*) AS total_orders FROM orders;
SELECT status, COUNT(*) AS count, SUM(total_amount) AS revenue 
FROM orders 
GROUP BY status;

-- ============================================================================
-- SEKCJA 4: TABELA DO TESTÓW WYDAJNOŚCI
-- ============================================================================

CREATE TABLE test_performance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_name VARCHAR(100),
    value INT,
    data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_test_name (test_name),
    INDEX idx_value (value)
) ENGINE=InnoDB;

-- ============================================================================
-- SEKCJA 5: WIDOKI POMOCNICZE
-- ============================================================================

-- Widok: Aktywni użytkownicy z zamówieniami
CREATE VIEW v_active_users_with_orders AS
SELECT 
    u.id,
    u.name,
    u.email,
    u.city,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.status = 'active'
GROUP BY u.id, u.name, u.email, u.city;

-- Widok: Produkty niskomagazynowe
CREATE VIEW v_low_stock_products AS
SELECT 
    id,
    name,
    category,
    stock,
    price,
    stock * cost AS inventory_value
FROM products
WHERE stock < 50
ORDER BY stock ASC;

-- Widok: Statystyki kategorii produktów
CREATE VIEW v_category_stats AS
SELECT 
    category,
    COUNT(*) AS product_count,
    AVG(price) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    SUM(stock) AS total_stock
FROM products
GROUP BY category;

-- ============================================================================
-- SEKCJA 6: PROCEDURY DO ĆWICZEŃ
-- ============================================================================

-- Procedura: Masowy INSERT dla testów wydajności
DELIMITER $$

CREATE PROCEDURE benchmark_insert(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    
    SET start_time = NOW(3);
    
    START TRANSACTION;
    WHILE i < num_rows DO
        INSERT INTO test_performance (test_name, value, data)
        VALUES (
            CONCAT('Test_', FLOOR(RAND() * 100)),
            FLOOR(RAND() * 10000),
            REPEAT('x', FLOOR(RAND() * 500))
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;
    
    SET end_time = NOW(3);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;
    
    SELECT 
        num_rows AS rows_inserted,
        duration AS seconds,
        ROUND(num_rows / duration, 2) AS rows_per_second;
END$$

-- Procedura: Masowy UPDATE dla testów MVCC
CREATE PROCEDURE benchmark_update(IN num_rows INT)
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    
    SET start_time = NOW(3);
    
    UPDATE products 
    SET price = price * 1.1 
    WHERE id <= num_rows;
    
    SET end_time = NOW(3);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;
    
    SELECT 
        num_rows AS rows_updated,
        duration AS seconds,
        ROUND(num_rows / duration, 2) AS rows_per_second;
END$$

-- Procedura: Symulacja transakcji z ROLLBACK
CREATE PROCEDURE demo_transaction_rollback()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction rolled back due to error' AS status;
    END;
    
    START TRANSACTION;
    
    -- Operacja 1: UPDATE salda użytkownika
    UPDATE users SET balance = balance - 100 WHERE id = 1;
    SELECT 'Step 1: Deducted 100 from user 1' AS step;
    
    -- Operacja 2: INSERT do orders
    INSERT INTO orders (user_id, total_amount, status)
    VALUES (1, 100.00, 'pending');
    SELECT 'Step 2: Created order' AS step;
    
    -- Symulacja błędu (dzielenie przez zero)
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Simulated error - transaction will rollback';
    
    COMMIT;
END$$

DELIMITER ;

-- ============================================================================
-- SEKCJA 7: ZAPYTANIA TESTOWE DO ĆWICZEŃ NA LEKCJI
-- ============================================================================

-- Ćwiczenie 1: Analiza EXPLAIN - const type
SELECT 'Exercise 1: EXPLAIN with PRIMARY KEY lookup' AS exercise;
EXPLAIN SELECT * FROM users WHERE id = 5000;

-- Ćwiczenie 2: Analiza EXPLAIN - ref type
SELECT 'Exercise 2: EXPLAIN with secondary index' AS exercise;
EXPLAIN SELECT * FROM users WHERE email = 'user1000@example.com';

-- Ćwiczenie 3: Analiza EXPLAIN - range type
SELECT 'Exercise 3: EXPLAIN with range scan' AS exercise;
EXPLAIN SELECT * FROM products WHERE price BETWEEN 100 AND 500;

-- Ćwiczenie 4: Analiza EXPLAIN - index scan
SELECT 'Exercise 4: EXPLAIN with index scan' AS exercise;
EXPLAIN SELECT category, COUNT(*) FROM products GROUP BY category;

-- Ćwiczenie 5: Analiza EXPLAIN - ALL (full table scan)
SELECT 'Exercise 5: EXPLAIN with full table scan (missing index)' AS exercise;
EXPLAIN SELECT * FROM users WHERE phone LIKE '%123%';

-- Ćwiczenie 6: JOIN z EXPLAIN
SELECT 'Exercise 6: EXPLAIN with JOIN' AS exercise;
EXPLAIN 
SELECT u.name, o.id, o.total_amount
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE u.city = 'Warszawa'
LIMIT 10;

-- Ćwiczenie 7: Covering index
SELECT 'Exercise 7: Covering index (index-only scan)' AS exercise;
EXPLAIN SELECT id, email FROM users WHERE email LIKE 'user1%';

-- ============================================================================
-- SEKCJA 8: MONITORING InnoDB - Przykładowe komendy
-- ============================================================================

-- Buffer Pool Status
SELECT 'Buffer Pool Configuration' AS info;
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'innodb_buffer_pool_instances';

-- Redo Log Configuration
SELECT 'Redo Log Configuration' AS info;
SHOW VARIABLES LIKE 'innodb_log_file_size';
SHOW VARIABLES LIKE 'innodb_log_files_in_group';
SHOW VARIABLES LIKE 'innodb_flush_log_at_trx_commit';

-- Doublewrite Buffer
SELECT 'Doublewrite Buffer Status' AS info;
SHOW VARIABLES LIKE 'innodb_doublewrite';

-- Change Buffer
SELECT 'Change Buffer Configuration' AS info;
SHOW VARIABLES LIKE 'innodb_change_buffering';
SHOW VARIABLES LIKE 'innodb_change_buffer_max_size';

-- Adaptive Hash Index
SELECT 'Adaptive Hash Index Status' AS info;
SHOW VARIABLES LIKE 'innodb_adaptive_hash_index';

-- ============================================================================
-- SEKCJA 9: STATYSTYKI DLA OPTIMIZERA
-- ============================================================================

-- Aktualizacja statystyk dla wszystkich tabel
ANALYZE TABLE users;
ANALYZE TABLE products;
ANALYZE TABLE orders;
ANALYZE TABLE order_items;

-- ============================================================================
-- SEKCJA 10: PRZYKŁADOWE SCENARIUSZE TESTOWE
-- ============================================================================

-- Scenariusz 1: Transakcja z wieloma operacjami
DELIMITER $$

CREATE PROCEDURE demo_complex_transaction()
BEGIN
    DECLARE new_order_id INT;
    
    START TRANSACTION;
    
    -- Krok 1: Utworzenie zamówienia
    INSERT INTO orders (user_id, total_amount, status)
    VALUES (1, 250.00, 'pending');
    
    SET new_order_id = LAST_INSERT_ID();
    
    -- Krok 2: Dodanie pozycji zamówienia
    INSERT INTO order_items (order_id, product_id, quantity, price_per_unit, subtotal)
    VALUES 
        (new_order_id, 100, 2, 50.00, 100.00),
        (new_order_id, 200, 3, 50.00, 150.00);
    
    -- Krok 3: Aktualizacja stanu magazynowego
    UPDATE products SET stock = stock - 2 WHERE id = 100;
    UPDATE products SET stock = stock - 3 WHERE id = 200;
    
    -- Krok 4: Aktualizacja salda użytkownika
    UPDATE users SET balance = balance - 250.00 WHERE id = 1;
    
    COMMIT;
    
    SELECT 'Complex transaction completed successfully' AS status;
    SELECT * FROM orders WHERE id = new_order_id;
END$$

DELIMITER ;

-- ============================================================================
-- PODSUMOWANIE I INFORMACJE
-- ============================================================================

SELECT '============================================' AS '';
SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY!' AS status;
SELECT '============================================' AS '';
SELECT '' AS '';
SELECT 'Database: innodb_lab' AS info;
SELECT 'Tables created:' AS info;
SELECT '  - users (100,000 rows)' AS info;
SELECT '  - products (100,000 rows)' AS info;
SELECT '  - orders (10,000 rows)' AS info;
SELECT '  - order_items (~30,000 rows)' AS info;
SELECT '  - test_performance (empty, for benchmarks)' AS info;
SELECT '' AS '';
SELECT 'Views created:' AS info;
SELECT '  - v_active_users_with_orders' AS info;
SELECT '  - v_low_stock_products' AS info;
SELECT '  - v_category_stats' AS info;
SELECT '' AS '';
SELECT 'Procedures created:' AS info;
SELECT '  - fill_users(num_rows)' AS info;
SELECT '  - fill_products(num_rows)' AS info;
SELECT '  - fill_orders(num_orders)' AS info;
SELECT '  - benchmark_insert(num_rows)' AS info;
SELECT '  - benchmark_update(num_rows)' AS info;
SELECT '  - demo_transaction_rollback()' AS info;
SELECT '  - demo_complex_transaction()' AS info;
SELECT '' AS '';
SELECT 'Ready for exercises!' AS status;
SELECT '============================================' AS '';

-- Pokaż przykładowe dane
SELECT 'Sample data from users:' AS info;
SELECT * FROM users LIMIT 5;

SELECT 'Sample data from products:' AS info;
SELECT * FROM products LIMIT 5;

SELECT 'Sample data from orders:' AS info;
SELECT * FROM orders LIMIT 5;
