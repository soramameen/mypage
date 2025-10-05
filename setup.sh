#!/bin/bash

set -e

echo "========================================="
echo "Docker & Docker Compose インストール開始"
echo "========================================="

# パッケージ更新
echo "パッケージを更新中..."
sudo apt update

# 必要なパッケージをインストール
echo "必要なパッケージをインストール中..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# DockerのGPGキーを追加
echo "DockerのGPGキーを追加中..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Dockerリポジトリを追加
echo "Dockerリポジトリを追加中..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Dockerをインストール
echo "Dockerをインストール中..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Docker Composeをインストール
echo "Docker Composeをインストール中..."
sudo apt install -y docker-compose-plugin

# ユーザーをdockerグループに追加
echo "ユーザーをdockerグループに追加中..."
sudo usermod -aG docker $USER

echo ""
echo "========================================="
echo "✅ インストール完了！"
echo "========================================="
echo ""
echo "次の手順："
echo "1. 一度ログアウトして再ログインしてください"
echo "2. deploy.sh を実行してアプリを起動してください"
echo ""
