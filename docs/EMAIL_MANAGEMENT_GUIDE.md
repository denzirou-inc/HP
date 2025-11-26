# メール管理システム完全ガイド

## 概要

このガイドでは、Denzirou Company Webプロジェクトのメールサーバーとメールアカウント管理システムの使用方法について説明します。

## システム構成

### メールサーバー
- **Docker Mailserver**: 本格的なメールサーバー
- **ドメイン**: denzirou.com  
- **自動初期化**: Docker起動時に自動的にメールボックス構造を作成
- **SSL/TLS**: Let's Encrypt証明書による暗号化

### 管理ツール
1. **コマンドライン管理ツール** (`scripts/email_manager.sh`)
2. **インタラクティブ管理パネル** (`scripts/email_admin.sh`)
3. **シンプルコマンド集** (`scripts/mail_commands.sh`)

## メールサーバー操作

### 基本操作

```bash
# サーバー起動
cd docker/mailserver
docker compose -f docker-compose.mailserver.yml up -d

# サーバー停止
docker compose -f docker-compose.mailserver.yml down

# 状態確認
docker compose -f docker-compose.mailserver.yml ps

# ログ確認
docker compose -f docker-compose.mailserver.yml logs -f mailserver
```

## メールアカウント管理

### 1. コマンドライン管理ツール

#### 基本コマンド

```bash
# アカウント一覧
./scripts/email_manager.sh list

# アカウント作成（自動パスワード生成）
./scripts/email_manager.sh create user@denzirou.com

# アカウント作成（カスタムパスワード）  
./scripts/email_manager.sh create user@denzirou.com mypassword

# アカウント削除
./scripts/email_manager.sh delete user@denzirou.com

# パスワード変更（自動生成）
./scripts/email_manager.sh password user@denzirou.com

# パスワード変更（カスタム）
./scripts/email_manager.sh password user@denzirou.com newpassword
```

#### クイック作成

```bash
# テスト用アカウント（test+日付@denzirou.com）
./scripts/email_manager.sh quick test

# 一時アカウント（temp+時刻@denzirou.com） 
./scripts/email_manager.sh quick temp

# 開発者用アカウント（dev+ユーザー名@denzirou.com）
./scripts/email_manager.sh quick dev
```

### 2. インタラクティブ管理パネル

```bash
# 管理パネル起動
./scripts/email_admin.sh
```

#### 機能
- 📋 アカウント一覧表示
- ➕ 新規アカウント作成
- ❌ アカウント削除
- 🔑 パスワード変更
- 🔍 アカウント検索
- 📊 統計情報表示
- 🚀 一括操作

### 3. シンプルコマンド集（サーバー上での直接操作）

```bash
# コマンド読み込み
source scripts/mail_commands.sh

# 基本操作
mail-list                      # アカウント一覧
mail-create user@denzirou.com  # アカウント作成
mail-delete user@denzirou.com  # アカウント削除
mail-password user@denzirou.com # パスワード変更

# クイック操作
mail-test                      # テストアカウント作成
mail-temp                      # 一時アカウント作成

# メールテスト
mail-send-test user@denzirou.com "Test Subject"  # テストメール送信
mail-check user@denzirou.com                     # 受信確認
```

## Makefileコマンド

### メール管理コマンド

```bash
# アカウント管理
make email-list                                    # アカウント一覧
make email-create EMAIL=user@denzirou.com         # アカウント作成
make email-create EMAIL=user@denzirou.com PASS=pw # パスワード指定作成
make email-delete EMAIL=user@denzirou.com         # アカウント削除
make email-password EMAIL=user@denzirou.com       # パスワード変更

# クイック作成
make email-quick-test                              # テストアカウント
make email-quick-temp                              # 一時アカウント

# 管理ツール
make email-admin                                   # 管理パネル起動
make email-stats                                   # 統計情報
make email-help                                    # ヘルプ表示
```

## 自動初期化システム

### 仕組み

1. **初期化コンテナ** (`mailserver-init`) がメールサーバーより先に実行
2. 必要なディレクトリ構造とpermissions設定を自動実行
3. **メールサーバー**が初期化完了後に起動
4. **初期化フック**により既存アカウントのメールボックス自動作成
5. **設定監視**により新規アカウント追加時も自動対応

### 初期化フック

- `init-hooks/01-auto-create-mailboxes.sh`: 起動時メールボックス自動作成
- `init-hooks/02-watch-accounts-changes.sh`: 設定変更監視

## トラブルシューティング

### よくある問題

#### 1. メールボックスが作成されない

**症状**: アカウントは作成されるがメールボックスディレクトリがない

**解決方法**:
```bash
# 手動でディレクトリ作成
docker exec -u root mailserver mkdir -p /var/mail/denzirou.com/username
docker exec -u root mailserver chown -R 5000:5000 /var/mail/denzirou.com/username

# INBOX作成
docker exec mailserver doveadm mailbox create -u user@denzirou.com INBOX
```

#### 2. メールサーバーが起動しない

**症状**: Docker composeで起動エラー

**解決方法**:
```bash
# ログ確認
docker compose -f docker-compose.mailserver.yml logs mailserver

# 初期化ログ確認
docker logs mailserver-init

# コンテナ再作成
docker compose -f docker-compose.mailserver.yml down --remove-orphans
docker compose -f docker-compose.mailserver.yml up -d
```

#### 3. メール送受信ができない

**症状**: アカウントは作成されるがメールが届かない

**解決方法**:
```bash
# ポート確認
docker exec mailserver netstat -an | grep LISTEN

# DNS設定確認
dig MX denzirou.com
dig A mail.denzirou.com

# SSL証明書確認
docker exec mailserver openssl x509 -in /etc/ssl/certs/mailserver.crt -noout -dates
```

### ログ確認

```bash
# メールサーバーログ
docker exec mailserver tail -f /var/log/mail/mail.log

# 初期化ログ
docker exec mailserver cat /var/log/mail/init-hooks.log

# アカウント変更ログ
docker exec mailserver cat /var/log/mail/account-changes.log
```

## セキュリティ設定

### 基本セキュリティ機能

- **Fail2Ban**: 不正アクセス防止
- **Rspamd**: スパムフィルタリング  
- **SSL/TLS**: 通信暗号化
- **SASL認証**: SMTP認証
- **レート制限**: メール送信制限

### セキュリティ設定ファイル

- `security/fail2ban-custom.conf`: Fail2Ban設定
- `security/fail2ban-filters.conf`: Fail2Banフィルター
- `security/postfix-security.cf`: Postfix追加セキュリティ設定

## 設定ファイル

### 主要設定

- `docker-compose.mailserver.yml`: メインDocker設定
- `data/dms/config/postfix-accounts.cf`: メールアカウント一覧
- `data/dms/config/postfix-virtual.cf`: エイリアス設定  
- `data/dms/config/postfix-main.cf`: Postfix追加設定

### 環境変数

重要な環境変数:
```bash
ENABLE_RSPAMD=1                    # Rspamdスパムフィルター
ENABLE_FAIL2BAN=1                  # Fail2Ban不正アクセス防止
SSL_TYPE=manual                    # SSL設定方式
DOVECOT_MAILBOX_FORMAT=maildir     # メールボックス形式
DEFAULT_QUOTA=500M                 # デフォルト容量制限
```

## バックアップ

### 推奨バックアップ対象

```bash
# 設定ファイル
data/dms/config/

# メールデータ  
data/dms/mail-data/

# SSL証明書（システム管理）
/etc/letsencrypt/live/mail.denzirou.com/
```

### バックアップコマンド例

```bash
# 設定バックアップ
tar -czf mailserver-config-$(date +%Y%m%d).tar.gz data/dms/config/

# メールデータバックアップ（注意：容量大）
tar -czf mailserver-data-$(date +%Y%m%d).tar.gz data/dms/mail-data/
```

## 参考資料

- [Docker Mailserver Documentation](https://docker-mailserver.github.io/docker-mailserver/edge/)
- [Postfix Configuration](http://www.postfix.org/documentation.html)
- [Dovecot Documentation](https://doc.dovecot.org/)
- [Let's Encrypt](https://letsencrypt.org/docs/)

## サポート

技術的な問題や質問については、プロジェクト管理者にお問い合わせください。