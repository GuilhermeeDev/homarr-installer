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

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl status docker

time 3

# --- Instalando o Homarr ---

cat > docker-compose.yml <<EOF
services:
  homarr:
    container_name: homarr
    image: ghcr.io/homarr-labs/homarr:latest
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./homarr/appdata:/appdata
    environment:
      - SECRET_ENCRYPTION_KEY=$(openssl rand -hex 32)
    ports:
      - "7575:7575"
EOF

# Adicionando o usuário ao grupo docker para evitar a necessidade de sudo
sudo usermod -aG docker $USER
clear
echo "Reinicie o servidor e faça login novamente para aplicar as mudanças de grupo."
time 3
# sudo reboot 
