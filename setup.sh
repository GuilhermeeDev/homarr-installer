#!/bin/bash

# --- Instalando Docker ---
sudo apt update && sudo apt upgrade -y
sudo apt install curl htop ca-certificates curl -y
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

# --- Criando ambiente do HomeServer ---

TZ=America/Sao_Paulo
HOMARR_KEY=$(openssl rand -hex 32)

# .ENV DE PORTAS DE SERVIÇOS
cat > .env << EOF
#VARIAVEIS GLOBAIS
TZ=$TZ

#HOMARR
HOMARR_PORT=7575
SECRET_ENCRYPTION_KEY=$HOMARR_KEY
HOMARR_PUID=1000
HOMARR_PGID=1000

#PORTAINER
PORTAINER_PORT=9000

#UPTIME-KUMA
UPTIMEKUMA_PORT=3001

#NGINX PROXY MANAGER
NGINX_PROXY_MANAGER_PORT1=1000
NGINX_PROXY_MANAGER_PORT2=1001
NGINX_PROXY_MANAGER_PORT3=1002

#FILEBROWSER
FILEBROWSER_PORT=1200
FILEBROWSER_PUID=1000
FILEBROWSER_PGID=1000
FILEBROWSER_USER=$USER
EOF

# ADICIONANDO O USUARIO AO GRUPO DOCKER PARA EVITAR O USO DE SUDO
sudo usermod -aG docker $USER

# CRIANDO PASTAS DO SERVIDOR
mkdir -p homeserver
mkdir -p homeserver/export
mkdir -p homeserver/data
mkdir -p homeserver/media
mkdir -p homeserver/backups

# COPIANDO CONTEUDO PRINCIPAL DO SERVIDOR PARA A PASTA DO SERVIDOR
mv docker-compose.yml homeserver/
mv .env homeserver/
