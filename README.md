# My Portfolio Site

完全自作のポートフォリオサイト

## 🛠️ 使用技術

### アプリケーション
- Ruby on Rails 8.0.3
- Ruby 3.4.3
- PostgreSQL 16
- Hotwire
- バニラCSS

### インフラ
- Docker
- Docker Compose
- Nginx

## 🚀 デプロイ手順（ChromeOS Debian仮想マシン）

### 1. リポジトリをクローン

```bash
git clone <このリポジトリのURL>
cd mypage
```

### 2. Dockerをインストール（初回のみ）

```bash
chmod +x setup.sh
./setup.sh
```

インストール後、**一度ログアウトして再ログイン**してください。

### 3. アプリケーションをデプロイ

```bash
chmod +x deploy.sh
./deploy.sh
```

RAILS_MASTER_KEYの入力を求められたら、提供されたキーを入力してください。

### 4. アクセス

ChromeOSブラウザで以下にアクセス：
- http://penguin.linux.test
- http://localhost

## 📝 その他のコマンド

### ログ確認
```bash
docker compose logs -f
```

### 停止
```bash
docker compose down
```

### 再起動
```bash
docker compose restart
```

### コンテナの状態確認
```bash
docker compose ps
```
