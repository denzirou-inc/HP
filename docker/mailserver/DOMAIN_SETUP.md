# ドメイン設定ガイド - Denzirou

## ドメイン構成

- **メールサーバー用**: `denzirou.com`
- **ホームページ用**: `denzirou.jp`
- **メールホスト名**: `mail.denzirou.com`

## 必要なDNSレコード設定

### denzirou.com（メール用ドメイン）

```
# A レコード
mail.denzirou.com.    IN  A     [VPSサーバーIP]

# MX レコード
denzirou.com.         IN  MX    10 mail.denzirou.com.

# SPF レコード（送信者検証）
denzirou.com.         IN  TXT   "v=spf1 mx ~all"

# DMARC レコード（なりすまし防止）
_dmarc.denzirou.com.  IN  TXT   "v=DMARC1; p=quarantine; rua=mailto:admin@denzirou.com"

# DKIM レコード（セットアップ後に追加）
mail._domainkey.denzirou.com. IN TXT "v=DKIM1; k=rsa; p=[公開鍵]"
```

### denzirou.jp（ホームページ用ドメイン）

```
# A レコード（ホームページ）
denzirou.jp.          IN  A     [ホームページサーバーIP]
www.denzirou.jp.      IN  A     [ホームページサーバーIP]

# CNAME レコード（オプション）
www.denzirou.jp.      IN  CNAME denzirou.jp.
```

## メールアドレス設定

### 作成されるメールアカウント

- `contact@denzirou.com` - お問い合わせ用メインアドレス
- `admin@denzirou.com` - 管理者用アドレス
- `postmaster@denzirou.com` - システム管理用アドレス

### エイリアス設定

```
# すべてのメールをcontactに転送
@denzirou.com → contact@denzirou.com

# 一般的なエイリアス
info@denzirou.com → contact@denzirou.com
support@denzirou.com → contact@denzirou.com
sales@denzirou.com → contact@denzirou.com
noreply@denzirou.com → contact@denzirou.com
```

## Next.jsアプリケーション設定

### 本番環境用環境変数

```env
# メール送信設定（Next.js用）
SMTP_HOST=mail.denzirou.com
SMTP_PORT=587
SMTP_USER=contact@denzirou.com
SMTP_PASS=[セットアップ時に生成されるパスワード]
MAIL_TO=contact@denzirou.com
MAIL_FROM=contact@denzirou.com
```

### Docker Compose設定の更新

```yaml
# docker/docker-compose.yml
services:
  web:
    environment:
      # 更新されたメール設定
      SMTP_HOST: mail.denzirou.com
      SMTP_PORT: 587
      SMTP_USER: contact@denzirou.com
      SMTP_PASS: ${SMTP_PASS}
      MAIL_TO: contact@denzirou.com
```

## セットアップ順序

### 1. DNSレコード設定

まず最初に以下のレコードを設定：

```bash
# 最低限必要なレコード
mail.denzirou.com.    IN  A     [VPSサーバーIP]
denzirou.com.         IN  MX    10 mail.denzirou.com.
denzirou.com.         IN  TXT   "v=spf1 mx ~all"
```

### 2. メールサーバー起動

```bash
cd docker/mailserver
./setup-mailserver.sh
```

### 3. DKIM設定

```bash
# DKIM鍵生成
docker exec mailserver setup config dkim

# 公開鍵取得
docker exec mailserver cat /tmp/docker-mailserver/opendkim/keys/denzirou.com/mail.txt

# 取得した公開鍵をDNSに設定
mail._domainkey.denzirou.com. IN TXT "v=DKIM1; k=rsa; p=[取得した公開鍵]"
```

### 4. DMARC設定

```bash
# DMARC レコード追加
_dmarc.denzirou.com.  IN  TXT   "v=DMARC1; p=quarantine; rua=mailto:admin@denzirou.com"
```

### 5. 動作確認

```bash
# DNS確認
dig MX denzirou.com
dig TXT denzirou.com
dig A mail.denzirou.com

# メールサーバー確認
telnet mail.denzirou.com 25
telnet mail.denzirou.com 587
telnet mail.denzirou.com 993
```

## セキュリティ強化

```bash
# セキュリティ強化スクリプト実行
./security-hardening.sh

# ファイアウォール設定
./security/firewall-rules.sh

# 監視開始
./security/monitoring.sh
```

## トラブルシューティング

### DNS設定確認

```bash
# MXレコード確認
dig MX denzirou.com

# SPFレコード確認
dig TXT denzirou.com

# Aレコード確認
dig A mail.denzirou.com

# DKIM確認
dig TXT mail._domainkey.denzirou.com

# DMARC確認
dig TXT _dmarc.denzirou.com
```

### メール送信テスト

```bash
# 外部テストツール
# https://www.mail-tester.com/
# https://mxtoolbox.com/SuperTool.aspx

# コマンドラインテスト
echo "Test message" | mail -s "Test Subject" test@gmail.com
```

### SSL証明書確認

```bash
# SSL証明書の確認
openssl s_client -connect mail.denzirou.com:465 -servername mail.denzirou.com

# 証明書有効期限確認
echo | openssl s_client -connect mail.denzirou.com:465 2>/dev/null | openssl x509 -noout -dates
```

## 運用チェックリスト

### 初期設定後

- [ ] DNSレコードが正しく設定されている
- [ ] SSL証明書が正常に取得されている  
- [ ] DKIM/SPF/DMARCが設定されている
- [ ] メールアカウントが作成されている
- [ ] セキュリティ設定が有効になっている

### 定期確認項目

- [ ] SSL証明書の有効期限確認
- [ ] メールログの確認
- [ ] スパム検出状況の確認
- [ ] ディスク容量の確認
- [ ] セキュリティアラートの確認

## 参考情報

- **VPSサーバー**: Sakura VPS
- **OS**: Ubuntu
- **メールサーバー**: Docker Mailserver
- **SSL証明書**: Let's Encrypt
- **セキュリティ**: Fail2ban, UFW, iptables