# 本番環境メールアカウント操作ガイド

本番サーバー上でのメールアカウント管理手順です。

## サーバー接続

```bash
ssh -i ~/.ssh/id_rsa_denzirou admin@denzirou.com
cd /opt/denzirou-multi-env/production
```

## 基本操作

### アカウント一覧を表示

```bash
./scripts/email_manager.sh list
```

### アカウント作成

```bash
# パスワード自動生成
./scripts/email_manager.sh create user@denzirou.com

# パスワード指定
./scripts/email_manager.sh create user@denzirou.com mypassword123
```

### アカウント削除

```bash
# 確認あり
./scripts/email_manager.sh delete user@denzirou.com

# 確認なし（即時削除）
./scripts/email_manager.sh delete user@denzirou.com --confirm
```

### パスワード変更

```bash
# 新しいパスワード自動生成
./scripts/email_manager.sh password user@denzirou.com

# パスワード指定
./scripts/email_manager.sh password user@denzirou.com newpassword123
```

## クイック作成

テストや一時利用向けのアカウントを素早く作成します。

```bash
# テストアカウント（test+日付@denzirou.com）
./scripts/email_manager.sh quick test

# 一時アカウント（temp+時刻@denzirou.com）
./scripts/email_manager.sh quick temp

# 開発者用アカウント（dev+ユーザー名@denzirou.com）
./scripts/email_manager.sh quick dev
```

## 管理パネル（インタラクティブ）

対話形式でアカウント管理を行います。

```bash
./scripts/email_admin.sh
```

機能:
- アカウント一覧表示
- アカウント作成
- アカウント削除
- パスワード変更
- アカウント検索
- 統計情報表示

## メールサーバー操作

### 状態確認

```bash
docker ps | grep mailserver
```

### 再起動

```bash
cd docker/mailserver
docker compose -f docker-compose.mailserver.yml restart
```

### ログ確認

```bash
# リアルタイムログ
docker logs -f mailserver

# メールログ
docker exec mailserver tail -f /var/log/mail/mail.log
```

## Docker直接コマンド

スクリプトを使わない場合の直接操作です。

```bash
# アカウント一覧
docker exec mailserver setup email list

# アカウント作成
docker exec mailserver setup email add user@denzirou.com password

# アカウント削除
docker exec mailserver setup email del user@denzirou.com

# パスワード変更（削除→再作成）
docker exec mailserver setup email del user@denzirou.com
docker exec mailserver setup email add user@denzirou.com newpassword
```

## トラブルシューティング

### メールボックスが作成されない場合

```bash
# 手動作成
docker exec -u root mailserver mkdir -p /var/mail/denzirou.com/username
docker exec -u root mailserver chown -R 5000:5000 /var/mail/denzirou.com/username

# INBOX作成
docker exec mailserver doveadm mailbox create -u user@denzirou.com INBOX
```

### メールサーバーが起動しない場合

```bash
# ログ確認
docker compose -f docker/mailserver/docker-compose.mailserver.yml logs

# コンテナ再作成
docker compose -f docker/mailserver/docker-compose.mailserver.yml down --remove-orphans
docker compose -f docker/mailserver/docker-compose.mailserver.yml up -d
```

### DNS確認

```bash
dig MX denzirou.com
dig A mail.denzirou.com
```

## 接続情報

| 項目 | 値 |
|------|------|
| ドメイン | denzirou.com |
| SMTPサーバー | mail.denzirou.com |
| SMTPポート | 587 (STARTTLS) / 465 (SSL) |
| IMAPサーバー | mail.denzirou.com |
| IMAPポート | 993 (SSL) |
| POP3ポート | 995 (SSL) |
