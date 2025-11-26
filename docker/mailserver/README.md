# Docker Mailserver for Denzirou

Sakura VPS Ubuntu環境でのdocker-mailserverを使用したメールサーバー構築

## 構成

- **メールサーバー**: docker-mailserver (Postfix + Dovecot)
- **SSL証明書**: Let's Encrypt (Certbot)
- **セキュリティ**: Rspamd, ClamAV, Fail2Ban, SpamAssassin
- **ドメイン**: denzirou.com
- **ホスト名**: mail.denzirou.com

## セットアップ手順

### 1. 前提条件

- Docker & Docker Composeがインストール済み
- ドメイン `denzirou.com` のDNS設定権限
- Sakura VPS Ubuntu環境

### 2. 初期セットアップ

```bash
# セットアップスクリプト実行
./setup-mailserver.sh
```

### 3. DNS設定

以下のDNSレコードを設定してください：

```
# A レコード
mail.denzirou.com.    IN  A     [サーバーIP]

# MX レコード  
denzirou.com.         IN  MX    10 mail.denzirou.com.

# SPF レコード
denzirou.com.         IN  TXT   "v=spf1 mx ~all"

# DMARC レコード
_dmarc.denzirou.com.  IN  TXT   "v=DMARC1; p=quarantine; rua=mailto:admin@denzirou.com"
```

### 4. DKIM設定

```bash
# DKIM鍵を生成
docker exec mailserver setup config dkim

# DKIM公開鍵を取得
docker exec mailserver cat /tmp/docker-mailserver/opendkim/keys/denzirou.com/mail.txt
```

取得した公開鍵をDNSのTXTレコードに設定してください。

### 5. ファイアウォール設定

```bash
# 必要なポートを開放
sudo ufw allow 25/tcp    # SMTP
sudo ufw allow 465/tcp   # SMTPS
sudo ufw allow 587/tcp   # Submission
sudo ufw allow 993/tcp   # IMAPS
```

## 管理コマンド

### メールアカウント管理

```bash
# アカウント追加
docker exec -it mailserver setup email add user@denzirou.com [password]

# アカウント削除
docker exec -it mailserver setup email del user@denzirou.com

# アカウント一覧
docker exec -it mailserver setup email list
```

### エイリアス管理

```bash
# エイリアス追加
docker exec -it mailserver setup alias add alias@denzirou.com user@denzirou.com

# エイリアス削除
docker exec -it mailserver setup alias del alias@denzirou.com
```

### ログ確認

```bash
# メールサーバーログ
docker-compose -f docker-compose.mailserver.yml logs -f mailserver

# Postfixログ
docker exec mailserver tail -f /var/log/mail/mail.log

# Dovecotログ
docker exec mailserver tail -f /var/log/mail/dovecot.log
```

### サービス管理

```bash
# 起動
docker-compose -f docker-compose.mailserver.yml up -d

# 停止
docker-compose -f docker-compose.mailserver.yml down

# 再起動
docker-compose -f docker-compose.mailserver.yml restart

# 状態確認
docker-compose -f docker-compose.mailserver.yml ps
```

## メール設定（クライアント用）

### IMAP設定
- **サーバー**: mail.denzirou.com
- **ポート**: 993
- **セキュリティ**: SSL/TLS

### SMTP設定
- **サーバー**: mail.denzirou.com
- **ポート**: 587 (STARTTLS) または 465 (SSL/TLS)
- **認証**: 必要
- **セキュリティ**: STARTTLS または SSL/TLS

## アプリケーション連携

Next.jsアプリケーションからの送信設定：

```env
SMTP_HOST=mail.denzirou.com
SMTP_PORT=587
SMTP_USER=contact@denzirou.com
SMTP_PASS=[設定したパスワード]
MAIL_TO=contact@denzirou.com
```

## トラブルシューティング

### SSL証明書の問題

```bash
# 証明書の再取得
docker exec certbot-mailserver certbot renew --force-renewal

# 証明書の確認
docker exec mailserver openssl s_client -connect mail.denzirou.com:465
```

### メール送信テスト

```bash
# テストメール送信
docker exec -it mailserver bash
echo "Test message" | mail -s "Test Subject" test@example.com
```

### パフォーマンス確認

```bash
# リソース使用量確認
docker stats mailserver

# メール関連プロセス確認
docker exec mailserver ps aux | grep -E "(postfix|dovecot|rspamd)"
```