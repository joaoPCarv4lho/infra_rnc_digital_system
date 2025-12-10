#!/bin/bash
set -e

# --- Atualiza sistema ---
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common

# --- Adiciona repositório do Docker ---
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# --- Instala Docker Compose V2 ---
DOCKER_COMPOSE_VERSION=v2.23.1
mkdir -p /usr/libexec/docker/cli-plugins
curl -SL \
  "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# --- Habilita Docker ---
systemctl enable docker
systemctl start docker

# --- Permite o usuário ubuntu usar docker sem sudo ---
usermod -aG docker ubuntu

# --- Libera portas no firewall (caso UFW esteja ativo) ---
if command -v ufw >/dev/null 2>&1; then
    ufw allow 22/tcp
    ufw allow 3000/tcp
    ufw allow 8000/tcp
    ufw allow 8085/tcp
fi

# --- Libera portas via iptables (fallback) ---
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
iptables -A INPUT -p tcp --dport 8085 -j ACCEPT

# --- Cria pasta da aplicação ---
mkdir -p /opt/app
cd /opt/app

# --- Baixa o arquivo docker-compose ---
curl -o docker-compose.yml \
  https://raw.githubusercontent.com/joaoPCarv4lho/infra_rnc_digital_system/main/docker-compose.yaml

# --- Inicia containers automaticamente ---
docker compose up -d
