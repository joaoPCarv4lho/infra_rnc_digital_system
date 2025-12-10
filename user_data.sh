#!/bin/bash
set -e  

apt-get update -y
apt-get install -y ca-certificates curl software-properties-common gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor \
  -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

DOCKER_COMPOSE_VERSION=v2.23.1
mkdir -p /usr/libexec/docker/cli-plugins
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/libexec/docker/cli-plugins/docker-compose

chmod +x /usr/libexec/docker/cli-plugins/docker-compose

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu

sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8085 -j ACCEPT


cd /opt/app

curl -o docker-compose.yml https://raw.githubusercontent.com/joaoPCarv4lho/infra_rnc_digital_system/main/docker-compose.yaml