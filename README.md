# Inception

Docker infrastructure project with NGINX, WordPress, and MariaDB.

## Setup

### 1. Create secrets (required before first launch)

```bash
./setup_secrets.sh
```

This will create the `secrets/` directory with default passwords. **Change them for production!**

### 2. Create data directories

```bash
mkdir -p /home/$USER/data/mariadb /home/$USER/data/wordpress
```

### 3. Build and launch

```bash
make all
```

### 4. Access

Open your browser: `https://vgalmich.42.fr`

Add to `/etc/hosts` if needed:
```bash
echo "127.0.0.1 vgalmich.42.fr" | sudo tee -a /etc/hosts
```

## Commands

- `make all` - Build and start all services
- `make up` - Start services
- `make down` - Stop services
- `make logs` - Show logs
- `make clean` - Clean containers
- `make fclean` - Full cleanup (data included)

## For evaluators

1. Run `./setup_secrets.sh`
2. Run `make all`
3. Access `https://vgalmich.42.fr`
