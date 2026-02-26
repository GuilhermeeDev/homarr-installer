#!/bin/bash

# --- Instalando Docker ---
sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# --- Criando ambiente do home server ---
SECRET_ENCRYPTION_KEY=$(openssl rand -hex 32)
NEXTCLOUD_POSTGRES_PASSWORD=$(openssl rand -hex 32)
GITEA_POSTGRES_PASSWORD=$(openssl rand -hex 32)
GITEA_SECRET_KEY=$(openssl rand -hex 32)
GITEA_SECRET_TOKEN=$(openssl rand -hex 32)

cat > .env <<EOF
# PADRAO DE VARIÁVEIS DE AMBIENTE PARA O DOCKER-COMPOSE
TZ=America/Sao_Paulo

#HOMARR
HOMARR_SECRET_KEY=$SECRET_ENCRYPTION_KEY

#NEXTCLOUD
NEXTCLOUD_POSTGRES_PASSWORD=$NEXTCLOUD_POSTGRES_PASSWORD

# GITEA
GITEA_POSTGRES_PASSWORD=$GITEA_POSTGRES_PASSWORD
GITEA_SECRET_KEY=$GITEA_SECRET_KEY
GITEA_INTERNAL_TOKEN=$GITEA_SECRET_TOKEN
PUID=1000
PGID=1000
EOF

cat > docker-compose.yml <<EOF
# Docker Compose para Home Lab - Configurações otimizadas e atualizadas
# Feito por: Guilherme de Souza

# -- SERVIÇOS INCLUÍDOS:
# - Homarr
# - Portainer
# - Uptime Kuma

# - Nginx Proxy Manager 

# - Nextcloud
# - Jellyfin
# - Immich
# - PiHole
# - WireGuard VPN
# - Duplicati Backup
# - Gitea

# -- CONFIGURAÇÕES PADRONIZADAS:
# - Rede: homelab (bridge)
# - Logging: json-file com rotação de logs (max-size: 50MB, max-file: 5)
# - Restart: unless-stopped para todos os serviços
# - Limites de memória e CPU configurados para cada serviço

networks:
  homelab:
    name: virtual_LAN_homelab
    driver: bridge

x-defaults: &defaults
  restart: unless-stopped

  networks:
    - homelab      

  env_file:
    - .env

  logging:
    driver: "json-file"
    options:
      max-size: "50MB"
      max-file: "5"

# ---- SERVIÇOS ---- #
services:

# HOMARR

  homarr:
    <<: *defaults
    image: ghcr.io/homarr-labs/homarr:latest
    container_name: homarr
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data/homarr:/appdata

    environment:
      SECRET_ENCRYPTION_KEY: ${HOMARR_SECRET_KEY}

    ports:
      - "7575:7575"

    mem_limit: 512MB
    cpus: '1.0'

# PORTAINER
  portainer:
    <<: *defaults
    image: portainer/portainer-ce:2.38.1-linux-amd64-alpine
    container_name: portainer
    ports:
      - "9000:9000"

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data/portainer:/data
    
    environment:
      TZ: ${TZ}

    mem_limit: 512MB
    cpus: '1.0'

# UPTIME KUMA
  uptime-kuma:
    <<: *defaults
    image: louislam/uptime-kuma:2-slim
    container_name: uptime-kuma
    ports:
      - "3001:3001"

    volumes:
      - ./data/uptime-kuma:/app/data
    
    environment:
      TZ: ${TZ}

    mem_limit: 256MB
    cpus: '1.0'

# NGINX PROXY MANAGER
  nginx-proxy:
    <<: *defaults
    image: jc21/nginx-proxy-manager:2
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "81:81"
      - "443:443"

    volumes:
      - ./data/nginx:/data
      - ./data/letsencrypt:/etc/letsencrypt
    
    mem_limit: 512MB
    cpus: '1.0'

# NEXTCLOUD
  nextcloud:
    <<: *defaults
    image: nextcloud:32.0.6
    container_name: nextcloud
    ports:
      - "8080:8080"

    volumes:
      - ./data/nextcloud/html:/var/www/html
      - ./data/nextcloud/data:/var/www/html/data
      - ./data/nextcloud/custom_apps:/var/www/html/custom_apps
      - ./data/nextcloud/config:/var/www/html/config
    
    environment:
      TZ: ${TZ}
      REDIS_HOST: redis_nextcloud
      POSTGRES_HOST: postgres_nextcloud
      POSTGRES_DB: db_nextcloud
      POSTGRES_USER: nextcloud
      POSTGRES_PASSWORD: ${NEXTCLOUD_POSTGRES_PASSWORD}

    mem_limit: 1GB
    cpus: '1.0'
    depends_on:
      - redis_nextcloud
      - postgres_nextcloud
    
  # -> REDIS do Nextcloud para cache e fila de tarefas
  redis:
    <<: *defaults
    container_name: redis_nextcloud
    image: redis:alpine
    mem_limit: 256MB
    cpus: '1.0'
    
  # -> Postgres do Nextcloud para banco de dados
  postgres:
    <<: *defaults
    container_name: postgres_nextcloud
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: db_nextcloud
      POSTGRES_USER: nextcloud
      POSTGRES_PASSWORD: ${NEXTCLOUD_POSTGRES_PASSWORD}
      
    volumes:
      - ./data/nextcloud/postgres_nextcloud:/var/lib/postgresql/data
    
    mem_limit: 512MB
    cpus: '1.0'
EOF

cat > rebuild-docker-compose.sh <<EOF
# Docker Compose para Home Lab - Configurações otimizadas e atualizadas
# Feito por: Guilherme de Souza

# -- SERVIÇOS INCLUÍDOS:
# - Homarr
# - Portainer
# - Uptime Kuma
# - Nginx Proxy Manager 

# - Nextcloud
# - Jellyfin
# - Immich
# - PiHole
# - WireGuard VPN
# - Duplicati Backup
# - Gitea

# -- CONFIGURAÇÕES PADRONIZADAS:
# - Rede: homelab (bridge)
# - Logging: json-file com rotação de logs (max-size: 50MB, max-file: 5)
# - Restart: unless-stopped para todos os serviços
# - Limites de memória e CPU configurados para cada serviço

networks:
  homelab:
    name: virtual_LAN_homelab
    driver: bridge

x-defaults: &defaults
  restart: unless-stopped

  networks:
    - homelab      

  env_file:
    - .env

  logging:
    driver: "json-file"
    options:
      max-size: "50MB"
      max-file: "5"

# ---- SERVIÇOS ---- #
services:

# HOMARR

  homarr:
    <<: *defaults
    image: ghcr.io/homarr-labs/homarr:latest
    container_name: homarr
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data/homarr:/appdata

    environment:
      SECRET_ENCRYPTION_KEY: ${HOMARR_SECRET_KEY}

    ports:
      - "7575:7575"

    mem_limit: 512MB
    cpus: '1.0'

# PORTAINER
  portainer:
    <<: *defaults
    image: portainer/portainer-ce:2.38.1-linux-amd64-alpine
    container_name: portainer
    ports:
      - "9000:9000"

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data/portainer:/data
    
    environment:
      TZ: ${TZ}

    mem_limit: 512MB
    cpus: '1.0'

# UPTIME KUMA
  uptime-kuma:
    <<: *defaults
    image: louislam/uptime-kuma:2-slim
    container_name: uptime-kuma
    ports:
      - "3001:3001"

    volumes:
      - ./data/uptime-kuma:/app/data
    
    environment:
      TZ: ${TZ}

    mem_limit: 256MB
    cpus: '1.0'

# NGINX PROXY MANAGER
  nginx-proxy:
    <<: *defaults
    image: jc21/nginx-proxy-manager:2
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "81:81"
      - "443:443"

    volumes:
      - ./data/nginx:/data
      - ./data/letsencrypt:/etc/letsencrypt
    
    mem_limit: 512MB
    cpus: '1.0'

EOL
EOF

# Adicionando o usuário ao grupo docker para evitar a necessidade de sudo
sudo usermod -aG docker $USER

mkdir -p homelab
mkdir -p homelab/data
mkdir -p homelab/media
mkdir -p homelab/backups
mkdir -p homelab/data/nginx-proxy-manager
mkdir -p homelab/data/letsencrypt
mkdir -p homelab/data/uptime-kuma
mkdir -p homelab/data/portainer

mv docker-compose.yml homelab/
mv .env homelab/
chmod +x rebuild-docker-compose.sh
mv rebuild-docker-compose.sh homelab/
