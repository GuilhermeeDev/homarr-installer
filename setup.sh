#!/bin/bash

# --- Instalando Docker ---
# sudo apt update
# sudo apt install ca-certificates curl -y
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc

# sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
# Types: deb
# URIs: https://download.docker.com/linux/ubuntu
# Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
# Components: stable
# Signed-By: /etc/apt/keyrings/docker.asc
# EOF

# sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

SECRET_ENCRYPTION_KEY=$(openssl rand -hex 32)
DB_PASSWORD=$(openssl rand -hex 16)
POSTGRES_PASSWORD=$(openssl rand -hex 16)
WEBPASSWORD=$(openssl rand -hex 16)

cat > .env <<EOF
SECRET_ENCRYPTION_KEY=$SECRET_ENCRYPTION_KEY
DB_HOSTNAME=immich-db
DB_USERNAME=admin
DB_PASSWORD=$DB_PASSWORD
DB_DATABASE_NAME=imagens
POSTGRES_USER=admin
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=imagens
TZ=America/Sao_Paulo
WEBPASSWORD=$WEBPASSWORD
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
# - Nextcloud
# - Jellyfin
# - Immich
# - PiHole
# - WireGuard VPN
# - Nginx Proxy Manager
# - Duplicati Backup
# - Gitea
# Configurações de recursos e logging otimizados para desempenho e estabilidade

# -- CONFIGURAÇÕES PADRONIZADAS:
# - Rede: homelab (bridge)
# - Logging: json-file com rotação de logs (max-size: 50MB, max-file: 5)
# - Restart: unless-stopped para todos os serviços
# - Limites de memória e CPU configurados para cada serviço

networks:
  homelab:
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
      - ./homarr/appdata:/appdata
    ports:
      - "7575:7575"
    mem_limit: 512MB
    cpus: '0.5'

# PORTAINER
  portainer:
    <<: *defaults
    image: portainer/portainer-ce:2.38.1-linux-amd64-alpine
    container_name: portainer
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./portainer:/data
    mem_limit: 256MB
    cpus: '0.5'

# UPTIME KUMA
  uptime-kuma:
    <<: *defaults
    image: louislam/uptime-kuma:2-slim
    container_name: uptime-kuma
    ports:
      - "3001:3001"
    volumes:
      - ./uptime-kuma:/app/data
    mem_limit: 256MB
    cpus: '0.5'

# NEXTCLOUD
  nextcloud:
    <<: *defaults
    image: nextcloud:32.0.6
    container_name: nextcloud
    ports:
      - "8080:80"
    volumes:
      - ./nextcloud:/var/www/html
    mem_limit: 512MB
    cpus: '1.0'

# JELLYFIN
  jellyfin:
    <<: *defaults
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    ports:
      - "8096:8096"
    volumes:
      - ./jellyfin/config:/config
      - ./media:/media  
    mem_limit: 1024MB
    cpus: '1.0'

# IMMICH
  immich-server:
    <<: *defaults
    image: ghcr.io/immich-app/immich-server
    container_name: immich
    ports:
      - "2283:2283"
    volumes:
      - ./immich:/usr/src/app/upload
    depends_on:
      - immich-db
    mem_limit: 512MB
    cpus: '1.0'

  immich-db:
    <<: *defaults
    image: postgres:14
    container_name: immich-db
    volumes:
      - ./immich/immich-db:/var/lib/postgresql/data
    mem_limit: 256MB
    cpus: '0.5'

# PIHOLE
  pihole:
    <<: *defaults
    image: pihole/pihole:2026.02.0
    container_name: pihole
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8081:80"
    volumes:
      - ./pihole:/etc/pihole
    mem_limit: 256MB
    cpus: '0.5'

# WIREGUARD VPN
  wireguard:
    <<: *defaults
    image: linuxserver/wireguard:amd64-latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
    ports:
      - "51820:51820/udp"
    volumes:
      - ./wireguard:/config
    mem_limit: 256MB
    cpus: '0.5'

# NGINX PROXY MANAGER
  npm:
    <<: *defaults
    image: jc21/nginx-proxy-manager:2
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./nginx:/data
      - ./letsencrypt:/etc/letsencrypt
    mem_limit: 512MB
    cpus: '1.0'

# DUPLICATI BACKUP
  duplicati:
    <<: *defaults
    image: lscr.io/linuxserver/duplicati:amd64-2.2.0
    container_name: duplicati
    ports:
      - "8200:8200"
    volumes:
      - ./duplicati:/config
      - ./backups:/backups
      - ./media:/source
    mem_limit: 512MB
    cpus: '1.0'

# GITEA
  gitea:
    <<: *defaults
    image: gitea/gitea:1
    container_name: gitea
    ports:
      - "3000:3000"
      - "2222:22"
    volumes:
      - ./gitea:/data
    mem_limit: 512MB
    cpus: '1.0'
EOF

cat > rebuild-docker-compose.sh <<EOF
#!/bin/bash
rm -rf docker-compose.yml
cat > docker-compose.yml <<EOL
# Docker Compose para Home Lab - Configurações otimizadas e atualizadas
# Feito por: Guilherme de Souza

# -- SERVIÇOS INCLUÍDOS:
# - Homarr
# - Portainer
# - Uptime Kuma
# - Nextcloud
# - Jellyfin
# - Immich
# - PiHole
# - WireGuard VPN
# - Nginx Proxy Manager
# - Duplicati Backup
# - Gitea
# Configurações de recursos e logging otimizados para desempenho e estabilidade

# -- CONFIGURAÇÕES PADRONIZADAS:
# - Rede: homelab (bridge)
# - Logging: json-file com rotação de logs (max-size: 50MB, max-file: 5)
# - Restart: unless-stopped para todos os serviços
# - Limites de memória e CPU configurados para cada serviço

networks:
  homelab:
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
      - ./homarr/appdata:/appdata
    ports:
      - "7575:7575"
    mem_limit: 512MB
    cpus: '0.5'

# PORTAINER
  portainer:
    <<: *defaults
    image: portainer/portainer-ce:2.38.1-linux-amd64-alpine
    container_name: portainer
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./portainer:/data
    mem_limit: 256MB
    cpus: '0.5'

# UPTIME KUMA
  uptime-kuma:
    <<: *defaults
    image: louislam/uptime-kuma:2-slim
    container_name: uptime-kuma
    ports:
      - "3001:3001"
    volumes:
      - ./uptime-kuma:/app/data
    mem_limit: 256MB
    cpus: '0.5'

# NEXTCLOUD
  nextcloud:
    <<: *defaults
    image: nextcloud:32.0.6
    container_name: nextcloud
    ports:
      - "8080:80"
    volumes:
      - ./nextcloud:/var/www/html
    mem_limit: 512MB
    cpus: '1.0'

# JELLYFIN
  jellyfin:
    <<: *defaults
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    ports:
      - "8096:8096"
    volumes:
      - ./jellyfin/config:/config
      - ./media:/media  
    mem_limit: 1024MB
    cpus: '1.0'

# IMMICH
  immich-server:
    <<: *defaults
    image: ghcr.io/immich-app/immich-server
    container_name: immich
    ports:
      - "2283:2283"
    volumes:
      - ./immich:/usr/src/app/upload
    depends_on:
      - immich-db
    mem_limit: 512MB
    cpus: '1.0'

  immich-db:
    <<: *defaults
    image: postgres:14
    container_name: immich-db
    volumes:
      - ./immich/immich-db:/var/lib/postgresql/data
    mem_limit: 256MB
    cpus: '0.5'

# PIHOLE
  pihole:
    <<: *defaults
    image: pihole/pihole:2026.02.0
    container_name: pihole
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8081:80"
    volumes:
      - ./pihole:/etc/pihole
    mem_limit: 256MB
    cpus: '0.5'

# WIREGUARD VPN
  wireguard:
    <<: *defaults
    image: linuxserver/wireguard:amd64-latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
    ports:
      - "51820:51820/udp"
    volumes:
      - ./wireguard:/config
    mem_limit: 256MB
    cpus: '0.5'

# NGINX PROXY MANAGER
  npm:
    <<: *defaults
    image: jc21/nginx-proxy-manager:2
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./nginx:/data
      - ./letsencrypt:/etc/letsencrypt
    mem_limit: 512MB
    cpus: '1.0'

# DUPLICATI BACKUP
  duplicati:
    <<: *defaults
    image: lscr.io/linuxserver/duplicati:amd64-2.2.0
    container_name: duplicati
    ports:
      - "8200:8200"
    volumes:
      - ./duplicati:/config
      - ./backups:/backups
      - ./media:/source
    mem_limit: 512MB
    cpus: '1.0'

# GITEA
  gitea:
    <<: *defaults
    image: gitea/gitea:1
    container_name: gitea
    ports:
      - "3000:3000"
      - "2222:22"
    volumes:
      - ./gitea:/data
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
mkdir -p homelab/data/homarr/appdata
mkdir -p homelab/data/gitea
mkdir -p homelab/data/duplicati
mkdir -p homelab/data/nginx
mkdir -p homelab/data/letsencrypt
mkdir -p homelab/data/pihole
mkdir -p homelab/data/immich
mkdir -p homelab/data/immich/immich-db
mkdir -p homelab/data/jellyfin
mkdir -p homelab/data/nextcloud
mkdir -p homelab/data/uptime-kuma
mkdir -p homelab/data/portainer

mv docker-compose.yml homelab/
mv .env homelab/
chmod +x rebuild-docker-compose.sh
mv rebuild-docker-compose.sh homelab/
