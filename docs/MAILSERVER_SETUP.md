# メールサーバー完全ガイド

## 🎉 システム概要

### ✅ 完了済み構成

| 項目 | 状態 | 詳細 |
|------|------|------|
| **Docker Mailserver** | ✅ 稼働中 | Rspamd統一構成・セキュリティ強化 |
| **SSL/TLS** | ✅ 設定済 | mail.denzirou.com証明書・自動更新 |
| **DKIM署名** | ✅ 設定済 | 2048bit RSAキー・Rspamd統合 |
| **セキュリティ** | ✅ 強化済 | Fail2ban・ファイアウォール・監視 |
| **メールアカウント** | ✅ 作成済 | 3アカウント・認証テスト済 |
| **監視システム** | ✅ 稼働中 | 自動アラート・ログ監視 |

### 🔧 サーバー構成

```bash
# メールサーバー
Container: mailserver (UP)
Ports: 25→25, 465→465, 587→587, 993→993
SSL: /etc/letsencrypt/live/mail.denzirou.com/

# セキュリティ機能
- Rspamd: スパムフィルタ・DKIM・SPF・DMARC統合
- ClamAV: ウイルススキャン  
- TLS Required: 暗号化必須
- Modern TLS: TLSv1.2以上のみ
```

### 📧 作成済みメールアカウント

| アカウント | 用途 | パスワード場所 |
|------------|------|----------------|
| <contact@denzirou.com> | 問い合わせ用 | /opt/mailserver/data/dms/config/postfix-accounts.cf |
| <admin@denzirou.com> | 管理者用 | /opt/mailserver/data/dms/config/postfix-accounts.cf |
| <postmaster@denzirou.com> | システム用 | /opt/mailserver/data/dms/config/postfix-accounts.cf |

## 📋 必要なDNS設定

### 1. SPFレコード（スパム対策）

```dns
Type: TXT
Name: denzirou.com
Value: v=spf1 mx ~all
```

### 2. DMARCレコード（なりすまし対策）

```dns  
Type: TXT
Name: _dmarc.denzirou.com
Value: v=DMARC1; p=quarantine; rua=mailto:admin@denzirou.com
```

### 3. DKIMレコード（電子署名）

```dns
Type: TXT
Name: mail._domainkey.denzirou.com
Value: 
"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMI"
"IBCgKCAQEA6evS8yVy0wrOVU2Zbhr0wS660jpkFzRvTKidZAqjWp61AY"
"QdaEcfRtaQesGDT2KiyK+MnjKOXs3+JrvLZol1SdP+VVE7XoIITiDJ"
"z9DcGsMGNSw8969U8C1NEDM0/DBfjWTqPjBr8Kynd8Zm8P30IixhVw"
"Ts7lhGlr+HoQA8IxXPOtrQ6+xjOZtW6DkUfDnNQTJ6GJ7y0wxA9uy"
"KIk126akw9FDAXorcSw4RVcAHCrHcXONjc0fx/UZvxwGPAD7yCOVa0"
"j12DyFSEckhBWv9TabcqEaHT/JjGlyhjGyAcT+S6XsKm5OVSmk2ln0"
"pTBHcw1al8HaThGtXThmikvLpSQIDAQAB"
```

## 🔧 メールクライアント設定

### IMAP設定（受信）

```text
サーバー: mail.denzirou.com
ポート: 993
暗号化: SSL/TLS
認証: 通常のパスワード
```

### SMTP設定（送信）

```text
サーバー: mail.denzirou.com
ポート: 587 (STARTTLS) または 465 (SSL/TLS)
暗号化: STARTTLS または SSL/TLS
認証: 通常のパスワード
```

## 🛠️ 運用・メンテナンス

### パスワード確認

```bash
# メールアカウントのパスワード確認
sudo cat /opt/mailserver/data/dms/config/postfix-accounts.cf
```

### サービス管理

```bash
# メールサーバー状態確認
docker ps --filter name=mailserver

# ログ確認
docker logs mailserver --tail 50

# サービス再起動
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml restart mailserver
```

### SSL証明書更新

```bash
# 証明書は自動更新されるが、手動更新も可能
sudo certbot renew

# メールサーバー再起動で新証明書を反映
docker compose -f /opt/mailserver/docker-compose.mailserver.yml restart mailserver
```

### メールキューの確認

```bash
# 送信待ちメール確認
docker exec mailserver postqueue -p

# キュー削除
docker exec mailserver postsuper -d ALL
```

## 📊 セキュリティ監視

### 重要ログ

```bash
# メール送受信ログ
docker exec mailserver tail -f /var/log/mail/mail.log

# セキュリティログ
docker exec mailserver tail -f /var/log/mail/mail.warn
```

### 定期チェック項目

- [ ] SSL証明書有効期限（90日ごと自動更新）
- [ ] スパムメール状況
- [ ] ディスク使用量
- [ ] 不正アクセス試行

## 🚨 トラブルシューティング

### よくある問題

#### 1. メール送信できない

```bash
# SMTP認証確認
docker exec mailserver postconf | grep smtpd_sasl

# ポート確認
docker exec mailserver ss -tlnp | grep ':587\|:465'
```

#### 2. メール受信できない

```bash
# Dovecot確認
docker exec mailserver doveconf -n | grep ssl

# IMAP確認  
docker exec mailserver ss -tlnp | grep ':993'
```

#### 3. DKIM署名されない

```bash
# DKIM設定確認
docker exec mailserver cat /etc/rspamd/local.d/dkim_signing.conf

# Rspamd状態確認
docker exec mailserver rspamadm configtest
```

## 🔗 外部ツール

### メールテストツール

- **MX Toolbox**: <https://mxtoolbox.com/>
- **Mail Tester**: <https://www.mail-tester.com/>
- **DKIM Validator**: <https://dkimvalidator.com/>

### DNS確認

```bash
# DNS設定確認
dig MX denzirou.com
dig TXT denzirou.com  
dig TXT mail._domainkey.denzirou.com
```

---

**メールサーバーが正常に稼働中です！DNS設定完了後、本格運用を開始してください。**
