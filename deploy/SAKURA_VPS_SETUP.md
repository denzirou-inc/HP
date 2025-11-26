# Sakura VPS セットアップガイド

## 📋 概要

Sakura VPS上でのDenzirou Company Webプロジェクトのセットアップ手順

## 🚀 セットアップフロー

### 1. Sakura VPS初期設定
- VPS契約・起動
- 初期rootパスワード確認
- SSH接続確認

### 2. 管理ユーザー作成
- adminユーザーの作成
- SSH鍵認証設定
- セキュリティ強化

### 3. サーバー環境構築
- Docker環境構築
- SSL証明書設定
- 基本セキュリティ設定

### 4. アプリケーションデプロイ
- Webアプリケーション
- メールサーバー
- 監視システム

## 📝 詳細手順

### Step 1: Sakura VPS準備

#### 1.1 VPS申し込み・起動
1. Sakura VPSコントロールパネルでVPS作成
2. OSイメージ選択（Ubuntu 22.04 LTS推奨）
3. VPS起動・IPアドレス確認

#### 1.2 初期接続確認
```bash
# rootパスワードでの初回接続（コントロールパネルで確認）
ssh root@[VPS-IP-ADDRESS]
```

ssh ubuntu@denzirou.com

### Step 2: 管理ユーザー作成

#### 2.1 SSH鍵ペア作成（ローカル）
```bash
# SSH鍵ペア作成（まだない場合）
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "admin@denzirou.com"
```

#### 2.2 管理ユーザー作成スクリプト実行
```bash
# スクリプト実行
./deploy/create-admin-user.sh [VPS-IP-ADDRESS]

# 例
./deploy/create-admin-user.sh 192.168.1.100
```

このスクリプトが実行する内容：
- `admin` ユーザーの作成
- sudo権限の付与
- SSH公開鍵認証の設定
- パスワード認証の無効化
- rootユーザーSSHログインの無効化
- 基本パッケージのインストール

#### 2.3 接続確認
```bash
# 管理ユーザーでの接続テスト
ssh -i ~/.ssh/id_rsa admin@[VPS-IP-ADDRESS]
```

### Step 3: 設定ファイル編集

#### 3.1 デプロイ設定編集
```bash
vim deploy/config/production.env
```

必須設定項目：
```bash
# サーバー情報
SERVER_HOST=[VPS-IP-ADDRESS]
SERVER_USER=admin
SSH_KEY_PATH=~/.ssh/id_rsa

# ドメイン設定
WEB_DOMAIN=denzirou.jp
MAIL_DOMAIN=denzirou.com
MAIL_HOST=mail.denzirou.com

# SSL設定
SSL_EMAIL=admin@denzirou.com

# 通知設定
NOTIFICATION_EMAIL=admin@denzirou.com
```

### Step 4: DNS設定

#### 4.1 ドメイン設定
Aレコードとして以下を設定：
```
# Webサイト用
denzirou.jp.          IN  A    [VPS-IP-ADDRESS]
www.denzirou.jp.      IN  A    [VPS-IP-ADDRESS]

# メールサーバー用
mail.denzirou.com.    IN  A    [VPS-IP-ADDRESS]

# MXレコード
denzirou.com.         IN  MX   10 mail.denzirou.com.
```

### Step 5: サーバー環境構築

#### 5.1 サーバー初期セットアップ
```bash
./deploy/setup-server.sh
```

実行内容：
- Docker & Docker Compose インストール
- Node.js インストール
- Nginx インストール・設定
- Let's Encrypt SSL証明書取得
- UFW ファイアウォール設定
- システム監視設定

### Step 6: アプリケーションデプロイ

#### 6.1 Webアプリケーションデプロイ
```bash
# 統合デプロイ
./deploy/deploy.sh production all

# または個別デプロイ
./deploy/deploy.sh production web
./deploy/deploy.sh production mail
```

#### 6.2 動作確認
```bash
# 監視ダッシュボード
./deploy/monitor.sh production

# 手動確認
curl https://denzirou.jp
telnet mail.denzirou.com 25
```

### Step 7: メール設定完了

#### 7.1 DKIM設定
```bash
# サーバーでDKIM設定
ssh admin@[VPS-IP-ADDRESS]
cd /opt/denzirou-company-web/docker/mailserver
docker exec mailserver setup config dkim

# 公開鍵取得
docker exec mailserver cat /tmp/docker-mailserver/opendkim/keys/denzirou.com/mail.txt
```

#### 7.2 追加DNS設定
取得した公開鍵をDNSに設定：
```
# SPF レコード
denzirou.com.         IN  TXT  "v=spf1 mx ~all"

# DKIM レコード
mail._domainkey.denzirou.com. IN TXT "v=DKIM1; k=rsa; p=[取得した公開鍵]"

# DMARC レコード  
_dmarc.denzirou.com.  IN  TXT  "v=DMARC1; p=quarantine; rua=mailto:admin@denzirou.com"
```

## 🔧 運用・メンテナンス

### 日常運用コマンド

```bash
# システム監視
./deploy/monitor.sh production --watch

# ログ確認
ssh admin@[VPS-IP-ADDRESS] 'docker logs -f [container-name]'

# アプリケーション更新
./deploy/deploy.sh production all

# 緊急時ロールバック
./deploy/rollback.sh production all --force
```

### 定期メンテナンス

```bash
# バックアップ確認
./deploy/rollback.sh production all --list

# システム更新
ssh admin@[VPS-IP-ADDRESS] 'sudo apt update && sudo apt upgrade'

# SSL証明書確認
./deploy/monitor.sh production
```

## 🚨 トラブルシューティング

### よくある問題と解決法

#### 1. SSH接続できない
```bash
# 接続確認
ssh -v admin@[VPS-IP-ADDRESS]

# SSH鍵確認
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa
```

#### 2. SSL証明書エラー
```bash
# 証明書再取得
ssh admin@[VPS-IP-ADDRESS]
sudo certbot --nginx -d denzirou.jp --force-renewal
```

#### 3. メール送信できない
```bash
# メールサーバーログ確認
ssh admin@[VPS-IP-ADDRESS]
docker logs mailserver

# SMTP接続テスト
telnet mail.denzirou.com 587
```

#### 4. Docker関連エラー
```bash
# Docker状態確認
ssh admin@[VPS-IP-ADDRESS]
sudo systemctl status docker
docker ps

# Docker再起動
sudo systemctl restart docker
```

### 緊急時復旧手順

#### 1. サービス全停止時
```bash
# 即座にロールバック
./deploy/rollback.sh production all --force

# 手動復旧
ssh admin@[VPS-IP-ADDRESS]
cd /opt/denzirou-company-web
docker compose -p denzirou-company-web down
docker compose -p denzirou-company-web up -d
```

#### 2. 完全障害時
```bash
# 新しいVPSで復旧
./deploy/create-admin-user.sh [NEW-VPS-IP]
./deploy/setup-server.sh
./deploy/deploy.sh production all --force
```

## 📞 サポート情報

### 設定ファイル場所
- メイン設定: `deploy/config/production.env`
- ログファイル: `deploy/logs/`
- バックアップ: サーバー上の `/opt/backups/`

### 重要なサーバーパス
- アプリケーション: `/opt/denzirou-company-web/`
- バックアップ: `/opt/backups/denzirou-company-web/`
- SSL証明書: `/etc/letsencrypt/live/`

### 連絡先
- システム管理: admin@denzirou.com
- 技術サポート: support@denzirou.com

---

このガイドに従ってセットアップを行うことで、安全で運用しやすいSakura VPS環境が構築できます。