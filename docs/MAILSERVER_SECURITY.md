# メールサーバー セキュリティガイド

## 🔒 セキュリティ概要

### 実装済みセキュリティ機能

| セキュリティ層 | 機能 | 状態 | 詳細 |
|---------------|------|------|------|
| **ネットワーク層** | UFWファイアウォール | ✅ 稼働中 | ポート制限・レート制限 |
| **アプリケーション層** | Fail2ban | ✅ 稼働中 | 不正アクセス自動BAN |
| **メール層** | Rspamd | ✅ 稼働中 | スパム・DKIM・SPF・DMARC |
| **暗号化層** | TLS/SSL | ✅ 強化済 | TLSv1.2以上・強力暗号化 |
| **認証層** | SASL認証 | ✅ 強化済 | 認証遅延・失敗制限 |
| **監視層** | 自動監視 | ✅ 稼働中 | リアルタイムアラート |

## 🛡️ セキュリティ設定詳細

### 1. ファイアウォール設定（UFW）

```bash
# 現在の設定確認
sudo ufw status numbered

# 設定済みルール
Port 25 (SMTP): LIMIT - レート制限付き許可
Port 587 (Submission): LIMIT - レート制限付き許可  
Port 465 (SMTPS): ALLOW - SSL暗号化必須
Port 993 (IMAPS): ALLOW - SSL暗号化必須
Port 22 (SSH): LIMIT - 管理用レート制限
```

### 2. Fail2ban設定

```bash
# 保護対象サービス
- SSH: 3回失敗で2時間BAN
- SMTP認証: 3回失敗で2時間BAN  
- IMAP認証: 3回失敗で2時間BAN
- 繰り返し違反者: 7日間BAN

# 状態確認
docker exec mailserver fail2ban-client status

# BAN解除（緊急時）
docker exec mailserver fail2ban-client unban <IPアドレス>
```

### 3. メールサーバー強化設定

**Postfix セキュリティ機能:**

```bash
# RBLによるスパム対策
- Spamhaus Zen
- SpamCop
- SORBS

# レート制限
- 接続数: 10/IP
- 接続率: 30/分
- メッセージ率: 100/時間
- 受信者率: 200/時間

# TLS強化
- TLSv1.2以上必須
- 弱い暗号化除外
- Perfect Forward Secrecy対応
```

**Dovecot セキュリティ機能:**

```bash
# 接続制限
- 最大接続数: 20/IP
- 認証失敗遅延: 5秒
- 最大失敗回数: 3回

# TLS強化
- TLSv1.2以上必須
- 強力暗号化のみ許可
- 平文認証禁止
```

### 4. 監視・アラートシステム

```bash
# 監視スクリプト実行
/opt/mailserver/security/monitoring.sh

# 監視項目と閾値
- 認証失敗: 10回/時間でアラート
- 同時接続数: 100接続でアラート  
- ディスク使用量: 60%で警告、80%でアラート
- SSL証明書: 30日前に警告、7日前にアラート
- Fail2banステータス: 継続監視
```

## 🚨 セキュリティ運用

### 日常監視コマンド

```bash
# セキュリティ状況の総合確認
/opt/mailserver/security/monitoring.sh

# 認証失敗のみチェック
/opt/mailserver/security/monitoring.sh auth

# 現在の接続数確認
/opt/mailserver/security/monitoring.sh connections

# Fail2ban状態確認
/opt/mailserver/security/monitoring.sh fail2ban

# SSL証明書確認
/opt/mailserver/security/monitoring.sh ssl
```

### ログ確認

```bash
# セキュリティ監視ログ
tail -f /opt/mailserver/mailserver-security.log

# メール認証ログ
docker exec mailserver tail -f /var/log/mail/mail.log | grep "authentication"

# Fail2banログ
docker exec mailserver tail -f /var/log/fail2ban.log

# システムファイアウォールログ
sudo tail -f /var/log/ufw.log
```

### 緊急対応手順

#### 1. 大量攻撃を受けた場合

```bash
# 攻撃元IPを手動BAN
docker exec mailserver fail2ban-client set postfix banip <攻撃IP>

# 一時的にメールポート閉鎖
sudo ufw deny 25/tcp
sudo ufw deny 587/tcp

# 攻撃状況確認
docker exec mailserver tail -100 /var/log/mail/mail.log | grep REJECT
```

#### 2. アカウント侵害が疑われる場合

```bash
# 該当アカウント無効化
docker exec mailserver setup email del <侵害されたアカウント>

# パスワード緊急変更
docker exec mailserver setup email add <アカウント> <新パスワード>

# 関連ログ詳細確認
docker exec mailserver grep "<アカウント>" /var/log/mail/mail.log
```

#### 3. SSL証明書トラブル

```bash
# 証明書手動更新
sudo certbot renew --force-renewal -d mail.denzirou.com

# メールサーバー再起動で証明書反映
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml restart mailserver
```

## 📊 セキュリティ監査

### 定期チェック項目

**週次チェック:**

- [ ] Fail2banログの確認
- [ ] 認証失敗統計の確認
- [ ] ディスク使用量の確認
- [ ] 異常な接続パターンの確認

**月次チェック:**

- [ ] SSL証明書有効期限の確認
- [ ] セキュリティアップデート適用
- [ ] パスワードポリシーの見直し
- [ ] アクセスログの詳細分析

**四半期チェック:**

- [ ] セキュリティ設定の見直し
- [ ] 脅威インテリジェンス更新
- [ ] インシデント対応手順の訓練
- [ ] バックアップ・復旧テスト

### セキュリティテストコマンド

```bash
# メールポートスキャンテスト
nmap -p 25,587,465,993 mail.denzirou.com

# SSL設定テスト
openssl s_client -connect mail.denzirou.com:993 -servername mail.denzirou.com

# SMTP認証テスト
telnet mail.denzirou.com 587

# DNS設定検証
dig MX denzirou.com
dig TXT denzirou.com
dig TXT mail._domainkey.denzirou.com
```

## ⚠️ セキュリティ注意事項

### 設定変更時の注意点

1. **設定変更前**: 必ずバックアップを取得
2. **テスト実施**: 段階的に適用してテスト
3. **ログ監視**: 変更後はログを重点監視
4. **ロールバック準備**: 問題時の復旧手順を準備

### 避けるべき設定

- 平文認証の許可
- 弱いSSL/TLS設定
- 過度に緩いレート制限
- 監視の無効化
- デフォルトパスワードの使用

---

**このセキュリティガイドに従って適切な運用を行い、企業レベルのメールセキュリティを維持してください。**
