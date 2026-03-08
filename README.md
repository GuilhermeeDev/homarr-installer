# 🦀 Home Server com Docker + Homarr

<div align="center">
    <img src="https://img.shields.io/badge/Ubuntu-E95420?style=flat&logo=ubuntu&logoColor=white"></img>
    <img src="https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white"></img>
    <img src="https://img.shields.io/badge/bash_script-%23121011.svg?style=flat&logo=gnu-bash&logoColor=white"></img>
</div>

Este repositório contém a infraestrutura do meu Home Lab pessoal, construída sobre **Ubuntu Server + Docker Compose**, utilizando o Homarr como painel central de gerenciamento.

O objetivo do projeto é criar um ambiente estável, modular e escalável para hospedagem de serviços domésticos, monitoramento e experimentação com containers.

Faça um `fork` deste projeto e fique avontade para customizar o seu próprio docker-compose.

---

### 📌 Objetivos do Projeto

- Centralizar serviços domésticos em um único servidor
- Facilitar a administração via painel web (Homarr)
- Criar uma infraestrutura organizada e reproduzível
- Utilizar boas práticas de Docker Compose
- Otimizar uso de recursos (CPU e RAM)
- Permitir expansão futura do Home Lab

---

### Serviços Utilizados

| Serviço | Função |
|---------|-------|
| Homarr | Dashboard do Home Lab |
| Portainer | Gerenciamento de containers |
| Nginx Proxy Manager | Reverse Proxy |
| Uptime Kuma | Monitoramento de uptime |
| Pihole | DNS e bloqueador de anuncio|
|Wireguard | VPN |
|Gitea | GitHub pessoal|
| FileBrowser | Gerenciador de arquivos |

---
## Como rodar

certifique-se de ter o git instalado e openssh-server para configuração remota
```
sudo apt install openssh-server git -y
```

clone este repositorio
```
git clone https://github.com/GuilhermeeDev/homeserver-docker
cd homeserver-docker
```

rode o script de configuração inicial do projeto
```
./setup.sh
```

baixando os containeres do docker-compose
```
docker compose up -d
```

subindo os containeres do docker-compose
```
docker compose up
```
---

## Como acessar?
A princípio o seu painel de administrador roda por padrão na porta `7575` definida no `.env` da raiz do seu servidor.

descubra o ip do seu servidor
```bash
ip a
```

acesse no seu navegador
```
http://IP_SERVIDOR:7575
```
