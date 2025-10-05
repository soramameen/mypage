#!/bin/bash

set -e

echo "========================================="
echo "ngrokインストール開始"
echo "========================================="

# ngrokダウンロード
echo "ngrokをダウンロード中..."
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz

# 解凍
echo "解凍中..."
tar xvzf ngrok-v3-stable-linux-amd64.tgz

# 移動
echo "インストール中..."
sudo mv ngrok /usr/local/bin/

# 後片付け
rm ngrok-v3-stable-linux-amd64.tgz

echo ""
echo "========================================="
echo "✅ ngrokインストール完了！"
echo "========================================="
echo ""
echo "次のコマンドで公開："
echo "  ngrok http 8080"
echo ""
