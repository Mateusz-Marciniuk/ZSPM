# Lekcja: Uruchomienie bazy danych MySQL i aplikacji BookStack w kontenerach Docker (90 min)
## Wymagania wstępne

- Zainstalowany Docker i Docker Compose
- Podstawowa znajomość terminala Linux


### 1. Wprowadzenie do Docker i kontenerów

Docker to platforma do tworzenia, dystrybucji i uruchamiania aplikacji w izolowanych środowiskach zwanych kontenerami. Kontenery są lekkie, ponieważ współdzielą jądro systemu operacyjnego, ale mają własne środowisko użytkownika, co zapewnia izolację aplikacji i ich zależności.

#### Kontenery vs Maszyny Wirtualne

```
┌─────────────────────────┐     ┌─────────────────────────┐
│   Kontener Docker       │     │   Maszyna Wirtualna     │
├─────────────────────────┤     ├─────────────────────────┤
│ App A │ App B │ App C   │     │ App A                   │
├───────┴───────┴─────────┤     ├─────────────────────────┤
│   Docker Engine         │     │ Guest OS                │
├─────────────────────────┤     ├─────────────────────────┤
│   Host OS               │     │ Hypervisor              │
├─────────────────────────┤     ├─────────────────────────┤
│   Infrastruktura        │     │ Host OS                 │
└─────────────────────────┘     ├─────────────────────────┤
                                │ Infrastruktura          │
                                └─────────────────────────┘
```

#### Cykl życia kontenera

### Cykl życia kontenera

```
     ┌──────────┐
     │  Obraz   │
     └────┬─────┘
          │ docker run / create
          ▼
     ┌──────────┐
     │ Created  │
     └────┬─────┘
          │ docker start
          ▼
     ┌──────────┐
     │ Running  │
     └────┬─────┘
          │ docker stop
          ▼
     ┌──────────┐
     │ Stopped  │
     └────┬─────┘
          │ docker rm
          ▼
     ┌──────────┐
     │ Removed  │
     └──────────┘
```

- **Tworzenie** — tworzymy kontener z obrazu (np. `docker create` albo `docker run` z automatycznym tworzeniem)
- **Uruchamianie** — startujemy kontener, który wtedy działa (np. `docker start` lub `docker run`)
- **Zatrzymywanie** — zatrzymujemy działający kontener bez usuwania (np. `docker stop`)
- **Usuwanie** — usuwamy kontener z systemu (np. `docker rm`)

Dzięki temu możemy łatwo zarządzać stanem usług w kontrolowany sposób.

#### Podstawowe polecenia Docker

| Polecenie | Opis |
| :-- | :-- |
| `docker run [opcje] obraz` | Tworzy i uruchamia nowy kontener z zadanego obrazu |
| `docker ps` | Lista działających kontenerów |
| `docker ps -a` | Lista wszystkich kontenerów, także zatrzymanych |
| `docker stop <kontener>` | Zatrzymuje działający kontener |
| `docker start <kontener>` | Uruchamia zatrzymany kontener |
| `docker restart <kontener>` | Restartuje kontener |
| `docker rm <kontener>` | Usuwa zatrzymany kontener |
| `docker logs <kontener>` | Pokazuje logi kontenera |
| `docker exec -it <kontener> bash` | Wejście do powłoki bash w działającym kontenerze |

### Podstawowa terminologia

- **Image (obraz)** - plik tylko do odczytu z aplikacją i jej zależnościami
- **Container (kontener)** - uruchomiona instancja obrazu
- **Volume (wolumin)** - trwałe przechowywanie danych
- **Network (sieć)** - komunikacja między kontenerami
- **Registry (rejestr)** - miejsce przechowywania obrazów (np. Docker Hub)



#### Instalacja dockera 
https://docs.docker.com/engine/install/ubuntu/


#### Ćwiczenie praktyczne 1: Pierwszy kontener 

```bash
# Krok 1: Uruchom nginx z mapowaniem portu
docker run -d --name web-server -p 8080:80 nginx

# Parametr -p 8080:80 mapuje:
# - port 8080 na hoście
# - na port 80 w kontenerze

# Krok 2: Sprawdź czy działa
curl http://localhost:8080
# lub otwórz przeglądarkę: http://localhost:8080

# Krok 3: Zobacz logi
docker logs web-server

# Krok 4: Sprzątanie
docker stop web-server
docker rm web-server
```


### 2. Uruchomienie bazy danych MySQL

```bash
# Uruchomienie MySQL w kontenerze:
docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=example -e MYSQL_DATABASE=bookstack -p 3306:3306 -d mysql:8

# Sprawdzenie czy kontener działa:
docker ps

# Podłączenie do bazy (np. z hosta):
mysql -h 127.0.0.1 -P 3306 -u root -p
```

### Uruchomienie MySQL z woluminem (trwałe dane)

```bash
# Utwórz wolumin Docker
docker volume create mysql_data

# Lista woluminów
docker volume ls

# Uruchom MySQL z woluminem
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=strongpassword \
  -e MYSQL_DATABASE=testdb \
  -v mysql_data:/var/lib/mysql \
  -p 3306:3306 \
  mysql:8.0
```

### Zmienne środowiskowe MySQL

- **MYSQL_ROOT_PASSWORD** - hasło użytkownika root (wymagane)
- **MYSQL_DATABASE** - utworzenie bazy danych przy starcie
- **MYSQL_USER** - utworzenie użytkownika aplikacyjnego
- **MYSQL_PASSWORD** - hasło dla użytkownika aplikacyjnego

### 3. Uruchomienie BookStack z docker-compose

Plik `docker-compose.yml`:

```yaml
version: "3.7"
services:
  mysql:
    image: mysql:8
    container_name: bookstack_mysql
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: bookstack
      MYSQL_USER: bookstack
      MYSQL_PASSWORD: secret
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped

  bookstack:
    image: linuxserver/bookstack
    container_name: bookstack_app
    environment:
      - DB_HOST=mysql
      - DB_USER=bookstack
      - DB_PASS=secret
      - DB_DATABASE=bookstack
    ports:
      - 6875:80
    depends_on:
      - mysql
    restart: unless-stopped

volumes:
  mysql_data:
```

Uruchom aplikację:

```bash
docker-compose up -d
```
#### Dane do logowania do aplikacji 
admin@admin.com / password  <br>
Dokumentacja: https://www.bookstackapp.com/docs/admin/installation/


Sprawdź logi:

```bash
docker-compose logs -f bookstack
```


### 4. Podsumowanie

- Zatrzymanie: `docker-compose down`
- Podstawowe polecenia:
    - `docker ps` - lista działających kontenerów
    - `docker logs <container>` - logi kontenera

***

## Ćwiczenie

1. Zmień hasło do bazy w pliku `docker-compose.yml`, zatrzymaj i uruchom ponownie aplikację.
2. Połącz się z bazą danych z poziomu kontenera MySQL (np. użyj `docker exec -it bookstack_mysql mysql -u bookstack -p`).


