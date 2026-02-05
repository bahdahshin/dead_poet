# Dead Poet Backend

A minimal Haskell backend for posting and sharing poems. The API stores poems in memory for now.

## Requirements

- GHC + Cabal (e.g., via GHCup)

## Download without Git (e.g., NixOS VM)

```bash
curl -L -o dead_poet.tar.gz https://github.com/bahdahshin/dead_poet/archive/refs/heads/main.tar.gz
```

## Extract and enter the project

```bash
tar -xzf dead_poet.tar.gz
cd dead_poet-main
```

## Run locally

```bash
cabal update
cabal run dead-poet-server
```

The server listens on `http://localhost:8080`.

## Run with Docker

```bash
docker compose up --build
```

The container exposes `http://localhost:8080`.

## NixOS setup for Docker Compose

1. From the repo root, copy the module into your NixOS configuration directory.
   ```bash
   cd /path/to/dead_poet
   sudo cp nixos/docker-compose.nix /etc/nixos/docker-compose.nix
   ```
2. If your NixOS user is not `nixos`, update `/etc/nixos/docker-compose.nix` to use your actual user name.
3. Import the module manually in `/etc/nixos/configuration.nix`:

```nix
{
  imports = [
    ./docker-compose.nix
  ];
}
```

4. Apply the configuration and re-login so the Docker group membership takes effect:

```bash
sudo nixos-rebuild switch
```

## API

### Health

```bash
curl http://localhost:8080/health
```

### Create a poem

```bash
curl -X POST http://localhost:8080/poems \
  -H 'Content-Type: application/json' \
  -d '{"newTitle":"Ode","newBody":"Hello","newAuthor":"Ada"}'
```

### List poems

```bash
curl http://localhost:8080/poems
```

### Fetch a poem by id

```bash
curl http://localhost:8080/poems/1
```
