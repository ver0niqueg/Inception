# Inception 🐳

Inception is a Docker infrastructure project that demonstrates containerization and orchestration concepts. It helps understand the following concepts: container management, Docker networking, volume persistence, service orchestration, and environment configuration.

## Table of contents

- [Highlights](#highlights)
- [Services](#services)
- [Definitions](#definitions)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)

## Highlights

- Multi-container Docker application using Docker Compose
- Nginx web server for reverse proxy and load balancing
- MariaDB database for persistent data storage
- WordPress application with full CMS functionality
- Network isolation between containers
- Volume persistence for databases and application files
- Environment variable configuration for security
- Automated service startup and health management
- SSL/TLS support with Nginx configuration

## Definitions

| Term | Description |
|------|-------------|
| Docker | Containerization platform for packaging applications |
| Container | Isolated, lightweight environment with all dependencies |
| Docker Compose | Tool for orchestrating multi-container applications |
| Image | Blueprint for creating containers |
| Volume | Persistent storage mechanism for container data |
| Network | Virtual network connecting multiple containers |
| Dockerfile | Configuration file for building Docker images |
| Reverse Proxy | Server that forwards requests to backend services |
| MariaDB | Open-source relational database management system |
| Nginx | High-performance web server and reverse proxy |
| WordPress | Content management system for web applications |
| Environment Variables | Configuration parameters passed to containers |

## Services

### Nginx
Web server and reverse proxy managing HTTP/HTTPS traffic, routing requests to WordPress and handling SSL certificates.

### MariaDB
Relational database service providing persistent storage for WordPress application data, user information, and content.

### WordPress
Content management system and web application deployed behind the Nginx reverse proxy, utilizing MariaDB for data persistence.

## Installation

Clone the repository:
```bash
git clone <git@github.com:ver0niqueg/42-Inception.git>
cd 42-Inception
```

Configure environment variables:
```bash
cp srcs/template.env srcs/.env
# Edit srcs/.env with your configuration
```

Build and start containers:
```bash
make
```

Stop services:
```bash
make down
```

Remove all containers and volumes:
```bash
make fclean
```

Clean up images:
```bash
make clean
```

## Usage

Start the infrastructure:
```bash
make
```

Access the application:
- **WordPress**: https://localhost
- **Database**: MariaDB running on localhost:3306

View running containers:
```bash
docker-compose -f srcs/docker-compose.yml ps
```

View container logs:
```bash
docker-compose -f srcs/docker-compose.yml logs -f
```

Stop the infrastructure:
```bash
docker-compose -f srcs/docker-compose.yml down
```

## Project Structure

```
Inception/
├── Makefile                 # Build automation
├── srcs/
│   ├── docker-compose.yml   # Multi-container orchestration
│   ├── template.env         # Environment configuration template
│   └── requirements/
│       ├── mariadb/         # Database container
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── 50-server.cnf
│       │   └── tools/
│       │       └── mdb-conf.sh
│       ├── nginx/           # Web server container
│       │   ├── Dockerfile
│       │   └── conf/
│       │       └── nginx.conf
│       └── wordpress/       # CMS container
│           ├── Dockerfile
│           └── tools/
│               └── wp_conf.sh
└── README.md
```

## Configuration

### Environment Variables
Configure the following in `srcs/.env`:
- Database credentials
- WordPress admin credentials
- Domain name
- SSL certificate paths

### Services Communication
- Nginx listens on ports 80/443
- MariaDB internal port 3306
- WordPress internal port 9000 (PHP-FPM)
- Docker network enables service-to-service communication

## Requirements

- Docker
- Docker Compose
- Make

---

vgalmich – 42 School Student
