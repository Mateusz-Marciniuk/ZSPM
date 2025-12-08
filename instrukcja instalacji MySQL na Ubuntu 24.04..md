# Pełna instrukcja instalacji MySQL na Ubuntu 24.04.03 LTS

## Przygotowanie systemu

### Aktualizacja repozytoriów

```bash
sudo apt update && sudo apt upgrade -y
```


### Sprawdzenie dostępności pakietu MySQL

```bash
apt-cache search mysql-server
```


## Instalacja MySQL Server

### Instalacja z domyślnych repozytoriów Ubuntu

```bash
sudo apt install mysql-server -y
```


### Weryfikacja instalacji

```bash
mysql --version
```

Przykładowe wyjście:

```
mysql Ver 8.0.41-0ubuntu0.24.04.1 for Linux on x86_64 ((Ubuntu))
```


## Konfiguracja usługi systemowej

### Włączenie automatycznego uruchamiania przy starcie systemu

```bash
sudo systemctl enable mysql
```


### Uruchomienie usługi MySQL

```bash
sudo systemctl start mysql
```


### Sprawdzenie statusu usługi

```bash
sudo systemctl status mysql
```


### Weryfikacja portów nasłuchiwania

```bash
sudo ss -antp | grep mysql
```

Przykładowe wyjście:

```
LISTEN 0 151 127.0.0.1:3306 0.0.0.0:* users:(("mysqld",pid=149925,fd=26))
LISTEN 0 70 127.0.0.1:33060 0.0.0.0:* users:(("mysqld",pid=149925,fd=21))
```


## Zabezpieczenie instalacji MySQL

### Uruchomienie skryptu zabezpieczającego

```bash
sudo mysql_secure_installation
```


### Konfiguracja podczas uruchamiania skryptu

1. **VALIDATE PASSWORD component**: Wybierz `Y` aby włączyć walidację haseł
2. **Password Validation Policy**: Wybierz `2` dla najsilniejszej polityki haseł
3. **New password**: Wprowadź silne hasło dla użytkownika root
4. **Re-enter new password**: Potwierdź hasło
5. **Do you wish to continue with the password provided?**: Wybierz `Y`
6. **Remove anonymous users?**: Wybierz `Y` (usuwa użytkowników anonimowych)
7. **Disallow root login remotely?**: Wybierz `Y` (wyłącza zdalne logowanie root)
8. **Remove test database and access to it?**: Wybierz `Y` (usuwa testową bazę danych)
9. **Reload privilege tables now?**: Wybierz `Y` (przeładowuje tabele uprawnień)

### Restart usługi po konfiguracji

```bash
sudo systemctl restart mysql
```


## Konfiguracja uwierzytelniania dla użytkownika root

### Logowanie do MySQL jako root

```bash
sudo mysql
```


### Ustawienie hasła dla użytkownika root

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'TwojesilneHaslo';
```


### Zastosowanie zmian

```sql
FLUSH PRIVILEGES;
```


### Wyjście z konsoli MySQL

```sql
EXIT;
```


### Test logowania z hasłem

```bash
mysql -u root -p
```


## Tworzenie użytkownika administracyjnego

### Logowanie jako root

```bash
mysql -u root -p
```


### Tworzenie nowego użytkownika

```sql
CREATE USER 'admin_user'@'localhost' IDENTIFIED WITH mysql_native_password BY 'SilneHasloAdmina';
```


### Nadawanie uprawnień (wszystkie uprawnienia)

```sql
GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'localhost' WITH GRANT OPTION;
```


### Alternatywnie - nadawanie wybranych uprawnień

```sql
GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, DROP, RELOAD ON *.* TO 'admin_user'@'localhost' WITH GRANT OPTION;
```


### Sprawdzenie nadanych uprawnień

```sql
SHOW GRANTS FOR 'admin_user'@'localhost';
```


### Zastosowanie zmian

```sql
FLUSH PRIVILEGES;
EXIT;
```


### Test logowania nowym użytkownikiem

```bash
mysql -u admin_user -p
```


## Konfiguracja zdalnego dostępu (opcjonalne)

### Edycja pliku konfiguracyjnego MySQL

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```


### Zmiana adresu nasłuchiwania

Znajdź linię:

```
bind-address = 127.0.0.1
```

Zmień na:

```
bind-address = 0.0.0.0
```


### Przeładowanie konfiguracji systemd

```bash
sudo systemctl daemon-reload
```


### Restart usługi MySQL

```bash
sudo systemctl restart mysql
```


### Utworzenie użytkownika dla zdalnego dostępu

```bash
mysql -u root -p
```

```sql
CREATE USER 'remote_user'@'%' IDENTIFIED WITH mysql_native_password BY 'SilneHasloZdalne';
GRANT ALL PRIVILEGES ON *.* TO 'remote_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```


### Konfiguracja firewall-a

```bash
# Otwarcie portu 3306 dla wszystkich
sudo ufw allow 3306

# Lub otwarcie tylko dla określonego IP
sudo ufw allow from ADRES_IP to any port 3306

# Przeładowanie firewall-a
sudo ufw reload
```


## Podstawowe operacje testowe

### Tworzenie przykładowej bazy danych

```sql
CREATE DATABASE test_database;
```


### Tworzenie tabeli

```sql
USE test_database;
CREATE TABLE test_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```


### Wstawianie danych

```sql
INSERT INTO test_table (name, description) VALUES 
('Test Item 1', 'Opis pierwszego elementu testowego'),
('Test Item 2', 'Opis drugiego elementu testowego');
```


### Sprawdzenie danych

```sql
SELECT * FROM test_table;
```


## Przydatne komendy administracyjne

### Sprawdzenie wersji MySQL

```sql
SELECT VERSION();
```


### Lista baz danych

```sql
SHOW DATABASES;
```


### Lista użytkowników

```sql
SELECT User, Host FROM mysql.user;
```


### Sprawdzenie procesów

```sql
SHOW PROCESSLIST;
```


### Wyświetlenie statusu

```sql
SHOW STATUS;
```


### Sprawdzenie zmiennych konfiguracyjnych

```sql
SHOW VARIABLES LIKE '%version%';
```


## Instalacja narzędzi dodatkowych

### MySQL Tuner (analiza wydajności)

```bash
sudo apt install mysqltuner -y
sudo mysqltuner
```


### MySQL Shell (zaawansowana konsola)

```bash
sudo apt install mysql-shell -y
```


## Lokalizacja ważnych plików

- **Główny plik konfiguracyjny**: `/etc/mysql/mysql.conf.d/mysqld.cnf`
- **Logi**: `/var/log/mysql/`
- **Dane**: `/var/lib/mysql/`
- **Socket**: `/var/run/mysqld/mysqld.sock`


## Komendy zarządzania usługą

```bash
# Start
sudo systemctl start mysql

# Stop  
sudo systemctl stop mysql

# Restart
sudo systemctl restart mysql

# Status
sudo systemctl status mysql

# Enable (automatyczne uruchamianie)
sudo systemctl enable mysql

# Disable (wyłączenie automatycznego uruchamiania)
sudo systemctl disable mysql
```


## Backup i przywracanie

### Tworzenie backupu

```bash
# Backup pojedynczej bazy
mysqldump -u root -p nazwa_bazy > backup_bazy.sql

# Backup wszystkich baz
mysqldump -u root -p --all-databases > backup_wszystkich.sql
```


### Przywracanie z backupu

```bash
# Przywracanie pojedynczej bazy
mysql -u root -p nazwa_bazy < backup_bazy.sql

# Przywracanie wszystkich baz
mysql -u root -p < backup_wszystkich.sql
```

To kończy kompletną instrukcję instalacji i konfiguracji MySQL 8.0 na Ubuntu 24.04.03 LTS. Instalacja obejmuje wszystkie kroki od podstawowej instalacji, przez zabezpieczenie, tworzenie użytkowników, konfigurację zdalnego dostępu, aż po podstawowe operacje administracyjne.[^1_1][^1_2][^1_3]
<span style="display:none">[^1_10][^1_11][^1_12][^1_13][^1_14][^1_15][^1_16][^1_17][^1_18][^1_19][^1_20][^1_4][^1_5][^1_6][^1_7][^1_8][^1_9]</span>

<div align="center">⁂</div>

[^1_1]: https://www.youtube.com/watch?v=455KKhZyvow

[^1_2]: https://docs.vultr.com/how-to-install-mysql-on-ubuntu-24-04

[^1_3]: https://www.cherryservers.com/blog/install-mysql-ubuntu-2404

[^1_4]: https://documentation.ubuntu.com/server/how-to/databases/install-mysql/

[^1_5]: https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-22-04

[^1_6]: https://geekrewind.com/how-to-install-mysql-8-0-on-ubuntu-24-04/

[^1_7]: https://dev.mysql.com/doc/mysql-getting-started/en/

[^1_8]: https://stackoverflow.com/questions/78825592/i-have-problem-installing-mysql-on-ubuntu-24-04

[^1_9]: https://www.modb.pro/db/1807337392052989952

[^1_10]: https://www.youtube.com/watch?v=zRfI79BHf3k

[^1_11]: https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04

[^1_12]: https://www.linuxtuto.com/how-to-install-mysql-8-4-on-ubuntu-24-04/

[^1_13]: https://www.linode.com/docs/guides/installing-and-configuring-mysql-on-ubuntu-2004/

[^1_14]: https://www.hostinger.com/tutorials/how-to-install-mysql-ubuntu

[^1_15]: https://qiita.com/studio_meowtoon/items/8905a84534b8f4cc680a

[^1_16]: https://www.linode.com/docs/guides/install-and-configure-mysql-on-ubuntu-22-04/

[^1_17]: https://www.alessioligabue.it/en/blog/install-mysql-ubuntu-2404-noble-numbat

[^1_18]: https://www.server-world.info/en/note?os=Ubuntu_24.04\&p=mysql8\&f=1

[^1_19]: https://documentation.ubuntu.com/server/how-to/databases/install-mysql/index.html

[^1_20]: https://vitux.com/how-to-install-and-configure-mysql-in-ubuntu/

