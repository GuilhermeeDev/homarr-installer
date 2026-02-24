# Homarr installer script
Script de instalação do Home Server Homarr

### Como rodar
rode a atualização inicial no ubuntu
```
sudo apt update && sudo apt upgrade -y
```

certifique-se de ter o git instalado
```
sudo apt install git -y
```

clone este repositorio
```
git clone https://github.com/GuilhermeeDev/homarr-installer
cd homarr-installer
```

rode o script de instalação
```
./setup.sh
```

### Como acessar o Home Server?
O home server a principio fica acessavel somente para dispositivos conectados a sua rede

baixando container Homarr
```
docker compose up -d
```

subindo o docker compose Homarr
```
docker compose up
```

descubra o ip do servidor
```bash
ip a
```

no seu navegador acesse
```
http://IP_SERVIDOR:7575
```