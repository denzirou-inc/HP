# Denzirou Company Web デプロイメントシステム

Sakura VPS Ubuntu環境での自動化されたデプロイメントシステム

## 🏗️ インフラ構成

詳細なインフラ構成図は [INFRASTRUCTURE.md](./INFRASTRUCTURE.md) を参照してください。

### 概要
- **サーバー**: Sakura VPS (Ubuntu 22.04) - `denzirou.com`
- **ホスト名**: `denzirou` (サーバー内部) / `denzirou.com` (外部アクセス)
- **本番環境**: nginx (Port 8080) → Next.js (内部)
- **開発環境**: nginx (Port 8081, Basic認証) → Next.js (内部)  
- **メールサーバー**: docker-mailserver (Ports 25,465,587,993)
- **セキュリティ**: UFW + Fail2ban + SSL/TLS

## 📁 ディレクトリ構成

```
deploy/
├── config/                    # 設定ファイル
│   ├── production.env        # 本番環境設定
│   ├── development.env       # 開発環境設定
│   └── deploy.conf          # 共通デプロイ設定
├── logs/                     # デプロイログ
├── setup-server.sh          # サーバー初期セットアップ
├── deploy-production.sh     # 本番環境デプロイ
├── deploy-development.sh    # 開発環境デプロイ
├── deploy-mail.sh           # メールサーバーデプロイ
├── monitor.sh               # システム監視
└── README.md                # このファイル
```

## 🚀 クイックスタート

### 1. 環境設定

```bash
# 設定ファイルを作成
cp config/production.env.example config/production.env
cp config/staging.env.example config/staging.env

# 設定を編集
vim config/production.env
```

### 2. サーバーセットアップ

```bash
# 初回のみ実行
./setup-server.sh production
```

### 3. アプリケーションデプロイ

```bash
# 本番環境デプロイ
./deploy-production.sh

# 開発環境デプロイ  
./deploy-development.sh

# メールサーバーデプロイ
./deploy-mail.sh production
```

## 📋 詳細ガイド

### 環境設定

#### production.env
```bash
# サーバー情報
SERVER_HOST=denzirou.com
SERVER_USER=admin
SSH_KEY_PATH=~/.ssh/id_rsa_denzirou

# ドメイン設定
WEB_DOMAIN=denzirou.jp
MAIL_DOMAIN=denzirou.com
MAIL_HOST=mail.denzirou.com

# Next.js設定
NODE_ENV=production
SMTP_HOST=mail.denzirou.com
SMTP_PORT=587
SMTP_USER=contact@denzirou.com
SMTP_PASS=your-password
MAIL_TO=contact@denzirou.com

# その他設定
PROJECT_NAME=denzirou-multi-env
DEPLOY_PATH=/opt/denzirou-multi-env
BACKUP_PATH=/opt/backups/denzirou-multi-env
```

### スクリプト詳細

#### setup-server.sh
サーバーの初期セットアップを自動実行
- システム更新
- Docker/Docker Compose インストール
- Node.js インストール
- 基本的なファイアウォール設定
- SSL証明書取得（Let's Encrypt）
- システム監視設定

```bash
./setup-server.sh production
```

#### deploy-production.sh
本番環境デプロイスクリプト
- Next.jsアプリケーションの本番デプロイ
- Nginxプロキシ設定
- 自動ヘルスチェック
- セキュアな設定（外部ポート最小化）

```bash
# 基本使用法
./deploy-production.sh [options]

# 例
./deploy-production.sh --force         # 強制デプロイ
```

#### deploy-development.sh  
開発環境デプロイスクリプト
- 開発用Next.jsアプリケーションデプロイ
- Basic認証付きNginxプロキシ
- 開発専用設定
- 本番環境とのポート分離

#### deploy-mail.sh
メールサーバー専用デプロイ
- docker-mailserverのセットアップ
- DNS設定確認
- セキュリティ強化
- DKIM設定ガイド

#### monitor.sh
システム監視ツール
- リアルタイム監視
- アラート通知
- パフォーマンス確認

```bash
./monitor.sh production --watch --alerts
```

## 🔧 ポート構成

### 現在のポート設定

| 環境 | サービス | ポート | 用途 |
|-----|---------|-------|------|
| **本番環境** | nginx | `8080` | メインアクセス |
| **開発環境** | nginx | `8081` | Basic認証付きアクセス |
| **本番環境** | Next.js | 内部のみ | nginx経由のみアクセス可 |
| **開発環境** | Next.js | 内部のみ | nginx経由のみアクセス可 |

### セキュリティ強化
- Next.jsコンテナは外部ポート非公開
- nginxプロキシが唯一の外部アクセスポイント
- 開発環境はBasic認証で保護

## 🔧 運用フロー

### 通常デプロイ

1. **準備**
   ```bash
   # 変更をコミット
   git add .
   git commit -m "feat: 新機能追加"
   git push origin main
   ```

2. **デプロイ実行**
   ```bash
   # 本番デプロイ
   ./deploy-production.sh
   
   # 強制デプロイ（確認スキップ）
   ./deploy-production.sh --force
   ```

3. **動作確認**
   ```bash
   # ヘルスチェック
   curl http://denzirou.com:8080/health
   
   # メインページ確認
   curl http://denzirou.com:8080/
   
   # 監視ダッシュボード
   ./monitor.sh production
   ```

## 📊 監視とメンテナンス

### ログ確認

```bash
# デプロイログ
tail -f deploy/logs/deploy-production-*.log

# システムログ（サーバー上）
ssh admin:denzirou_web 'journalctl -f'

# アプリケーションログ（サーバー上）
ssh admin:denzirou_web 'docker logs -f denzirou-prod-web'
```

### 定期メンテナンス

```bash
# システム状態確認
./monitor.sh production

# ディスク容量確認
ssh admin:denzirou_web 'df -h'

# Dockerコンテナ状態確認
ssh admin:denzirou_web 'docker ps'
```

## 🚨 トラブルシューティング

### よくある問題

1. **SSH接続失敗**
   ```bash
   # SSH設定確認
   ssh -T admin@denzirou.com
   
   # キーファイル権限確認
   chmod 600 ~/.ssh/id_rsa_denzirou
   ```

2. **Docker起動失敗**
   ```bash
   # Dockerサービス確認
   ssh admin:denzirou_web 'sudo systemctl status docker'
   
   # Docker再起動
   ssh admin:denzirou_web 'sudo systemctl restart docker'
   ```

3. **SSL証明書問題**
   ```bash
   # 証明書確認
   ./monitor.sh production
   
   # 手動更新
   ssh admin:denzirou_web 'sudo certbot renew --force-renewal'
   ```

4. **メール送信エラー**
   ```bash
   # メールサーバーログ確認
   ssh admin:denzirou_web 'docker logs mailserver'
   
   # SMTP接続テスト
   telnet mail.denzirou.com 587
   ```

5. **nginxプロキシヘルスチェック失敗**
   ```bash
   # 本番環境ヘルスチェック
   curl http://denzirou.com:8080/health
   
   # コンテナ状態確認
   ssh admin:denzirou_web 'docker ps | grep denzirou-prod'
   
   # nginxログ確認
   ssh admin:denzirou_web 'docker logs denzirou-prod-nginx'
   ```

### 緊急復旧手順

1. **サービス停止時**
   ```bash
   # コンテナ再起動
   ssh admin:denzirou_web 'cd /opt/denzirou-multi-env/production && docker compose -f docker/docker-compose.production.yml -p denzirou-production restart'
   ```

2. **完全障害時**
   ```bash
   # サーバー再セットアップ
   ./setup-server.sh production
   ./deploy-production.sh --force
   ```

## 📝 設定例

### SSH設定

ローカルの `~/.ssh/config` ファイルに以下を追加：

```bash
# Denzirou Production Server
Host denzirou_web
  HostName denzirou.com
  User admin
  IdentityFile ~/.ssh/id_rsa_denzirou
  ServerAliveInterval 60
  ServerAliveCountMax 3

# ショートカット設定
Host denzirou
  HostName denzirou.com
  User admin
  IdentityFile ~/.ssh/id_rsa_denzirou
```

### GitHub Actions連携

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
      
      - name: Deploy
        run: |
          ./deploy/deploy-production.sh --force
```

### Slack通知設定

```bash
# config/production.env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
NOTIFY_ON_SUCCESS=true
NOTIFY_ON_FAILURE=true
```

## 🔒 セキュリティ

- SSH鍵認証のみ使用
- ファイアウォール設定
- SSL証明書自動更新
- 定期的なセキュリティ更新
- ログ監視とアラート

## 📞 サポート

問題が発生した場合：

1. ログファイル確認
2. 監視ダッシュボードで状態確認
3. 必要に応じてロールバック実行
4. サポートチーム連絡：admin@denzirou.com

---

このデプロイメントシステムは、安全性と運用性を重視して設計されています。不明な点があれば、遠慮なくお問い合わせください。