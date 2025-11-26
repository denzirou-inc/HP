# デプロイメントガイド

## 🚀 デプロイ手順

### 事前準備

1. SSH設定が完了していること
2. Docker環境が構築済みであること
3. 必要な環境変数が設定済みであること

### 本番環境デプロイ

```bash
# 基本デプロイ
./deploy/deploy-production.sh

# 強制デプロイ（確認スキップ）
./deploy/deploy-production.sh --force

# バックアップなしデプロイ
./deploy/deploy-production.sh --no-backup
```

**実行内容:**

1. ファイル転送 (rsync)
2. 既存コンテナ停止
3. 新しいコンテナビルド・起動
4. ヘルスチェック実行（30回まで）

### 開発環境デプロイ

```bash
# 基本デプロイ
./deploy/deploy-development.sh

# 強制デプロイ（確認スキップ）
./deploy/deploy-development.sh --force
```

**実行内容:**

1. ファイル転送 (rsync)
2. 既存コンテナ停止
3. 開発環境用設定適用
4. 新しいコンテナビルド・起動
5. ヘルスチェック実行（20回まで）

## 🔧 設定管理

### 環境変数設定

**本番環境** (`deploy/config/production.env`):

```bash
ENVIRONMENT=production
SMTP_HOST=your-smtp-host
SMTP_PORT=587
SMTP_USER=your-smtp-user
SMTP_PASS=your-smtp-password
MAIL_TO=contact@denzirou.com
```

**開発環境** (`deploy/config/development.env`):

```bash
ENVIRONMENT=development
SMTP_HOST=
SMTP_PORT=
SMTP_USER=
SMTP_PASS=
MAIL_TO=dev@denzirou.com
```

### Basic認証設定（開発環境）

```bash
# パスワード変更
sudo htpasswd -c /opt/denzirou-multi-env/development/docker/nginx/.htpasswd_dev dev

# 複数ユーザー追加
sudo htpasswd /opt/denzirou-multi-env/development/docker/nginx/.htpasswd_dev newuser
```

## 📊 モニタリング・トラブルシューティング

### ヘルスチェック

```bash
# 本番環境
curl -I http://denzirou.jp/proxy-health
curl -I http://os3-379-22933.vs.sakura.ne.jp:8080/health

# 開発環境
curl -I -u dev:DevPass2025! http://dev.denzirou.jp/dev-info
curl -I -u dev:DevPass2025! http://os3-379-22933.vs.sakura.ne.jp:8081/health
```

### ログ確認

```bash
# デプロイログ
tail -f deploy/logs/deploy-production-YYYYMMDD_HHMMSS.log
tail -f deploy/logs/deploy-development-YYYYMMDD_HHMMSS.log

# コンテナログ
docker logs denzirou-prod-web
docker logs denzirou-prod-nginx
docker logs denzirou-dev-web
docker logs denzirou-dev-nginx

# システムログ
sudo journalctl -f -u nginx
```

### コンテナ状態確認

```bash
# 全コンテナ状態
docker ps -a

# 環境別確認
docker ps --filter name=denzirou-prod
docker ps --filter name=denzirou-dev

# リソース使用状況
docker stats
```

## 🛠️ トラブルシューティング

### よくある問題と対処法

#### 1. ヘルスチェック失敗

```bash
# コンテナ再起動
docker compose -f docker/docker-compose.production.yml -p denzirou-production restart

# ログ確認
docker logs denzirou-prod-web --tail 50
```

#### 2. ポート競合エラー

```bash
# ポート使用状況確認
sudo netstat -tlnp | grep ':8080\|:8081\|:80'

# 競合プロセス停止
sudo fuser -k 8080/tcp
```

#### 3. 権限エラー

```bash
# ディレクトリ権限修正
sudo chown -R admin:admin /opt/denzirou-multi-env/
sudo chmod -R 755 /opt/denzirou-multi-env/
```

#### 4. SSL証明書エラー

```bash
# 証明書更新
sudo certbot renew

# Nginx設定テスト
sudo nginx -t

# Nginx再起動
sudo systemctl reload nginx
```

### ロールバック手順

#### 本番環境ロールバック

```bash
# 直前のバックアップから復旧
cd /opt/denzirou-multi-env/production
sudo cp -r backup-YYYYMMDD_HHMMSS/* ./
docker compose -f docker/docker-compose.production.yml -p denzirou-production down
docker compose -f docker/docker-compose.production.yml \
  -p denzirou-production up -d
```

#### 開発環境ロールバック

```bash
# 開発環境は最新コードから再デプロイ
./deploy/deploy-development.sh --force
```

## 📋 定期メンテナンス

### 週次作業

- [ ] ログファイルの確認・クリーンアップ
- [ ] コンテナリソース使用状況確認
- [ ] SSL証明書の有効期限確認

### 月次作業

- [ ] システムアップデート (`sudo apt update && sudo apt upgrade`)
- [ ] Dockerイメージの更新 (`docker system prune -a`)
- [ ] バックアップファイルの整理

### SSL証明書管理

```bash
# 証明書情報確認
sudo certbot certificates

# 手動更新（テスト）
sudo certbot renew --dry-run

# 自動更新設定確認
sudo systemctl status certbot.timer
```

---

## まとめ

このガイドに従って安全で確実なデプロイを実行してください
