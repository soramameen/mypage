#!/bin/bash

set -e

echo "========================================="
echo "アプリケーションのデプロイを開始"
echo "========================================="

# .envファイルの確認
if [ ! -f .env ]; then
    echo ""
    echo "⚠️  .envファイルが見つかりません"
    echo ""
    read -p "RAILS_MASTER_KEYを入力してください: " master_key
    echo "RAILS_MASTER_KEY=$master_key" > .env
    echo "✅ .envファイルを作成しました"
    echo ""
fi

# 既存のコンテナを停止・削除
echo "既存のコンテナを停止中..."
docker compose down 2>/dev/null || true

# イメージをビルド
echo "Dockerイメージをビルド中..."
docker compose build

# コンテナを起動
echo "コンテナを起動中..."
docker compose up -d

echo ""
echo "========================================="
echo "✅ デプロイ完了！"
echo "========================================="
echo ""
echo "アクセス方法："
echo "  ChromeOSブラウザ: http://penguin.linux.test"
echo "  または: http://localhost"
echo ""
echo "ログ確認: docker compose logs -f"
echo "停止: docker compose down"
echo ""
