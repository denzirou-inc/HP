# メールサーバーセキュリティ強化ガイド

## 概要

このドキュメントは、Sakura VPS Ubuntu環境でのdocker-mailserverのセキュリティ対策について説明します。

## 実装されたセキュリティ対策

### 1. 基本セキュリティ設定

- **Rspamd**: スパムフィルタリング
- **ClamAV**: ウイルススキャン
- **Fail2Ban**: 侵入検知・防御システム
- **Postgrey**: グレイリスト機能
- **OpenDKIM/OpenDMARC**: メール認証
- **SPF Policy**: 送信者検証

### 2. 強化されたSSL/TLS設定

```yaml
TLS_LEVEL=modern
DOVECOT_TLS=required
SSL_TYPE=letsencrypt
POSTFIX_INET_PROTOCOLS=ipv4
```

- 現代的なTLS設定
- 必須暗号化通信
- 自動SSL証明書更新

### 3. アクセス制御とレート制限

```yaml
POSTFIX_REJECT_UNKNOWN_CLIENT_HOSTNAME=1
POSTFIX_REJECT_UNKNOWN_HELO_HOSTNAME=1
POSTFIX_REJECT_UNKNOWN_SENDER_DOMAIN=1
POSTFIX_REJECT_UNKNOWN_RECIPIENT_DOMAIN=1
POSTFIX_MESSAGE_SIZE_LIMIT=52428800
POSTFIX_MAILBOX_SIZE_LIMIT=1073741824
DEFAULT_QUOTA=1G
```

### 4. 高度なFail2Ban設定

#### 監視対象サービス
- SSH接続
- Postfix（SMTP認証、リレー拒否、不明ユーザー）
- Dovecot（IMAP認証）
- Nginx（Web攻撃）
- 辞書攻撃・DDoS攻撃

#### カスタムフィルター
- メール爆撃攻撃検出
- 不正なMXアクセス検出
- HELO/EHLO攻撃検出
- レート制限違反検出

### 5. ファイアウォール設定

#### UFW基本設定
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 25/tcp    # SMTP
sudo ufw allow 465/tcp   # SMTPS
sudo ufw allow 587/tcp   # SMTP Submission
sudo ufw allow 993/tcp   # IMAPS
```

#### iptables追加設定
- DDoS攻撃対策
- SYN flood攻撃対策
- ポートスキャン対策
- ICMP flood攻撃対策
- レート制限

### 6. セキュリティ監視

#### 自動監視項目
- 失敗したログイン試行
- Fail2ban状況
- メール送信量
- ディスク使用量
- SSL証明書有効期限
- サービス稼働状況
- スパム検出状況
- ネットワーク接続

#### アラート設定
- 閾値超過時の自動メール通知
- 管理者への即座な通知
- 詳細なログ記録

## セットアップ手順

### 1. セキュリティ強化の実行

```bash
# 全セキュリティ対策を自動実行
./security-hardening.sh
```

### 2. 個別設定の実行

```bash
# ファイアウォール設定のみ
./security/firewall-rules.sh

# 監視スクリプトの実行
./security/monitoring.sh
```

### 3. cron設定の確認

```bash
# 定期監視が設定されているか確認
crontab -l
```

## セキュリティチェックリスト

### 初期設定
- [ ] Docker Mailserverの起動
- [ ] SSL証明書の取得
- [ ] DKIM/SPF/DMARCの設定
- [ ] Fail2ban設定の適用
- [ ] ファイアウォール設定
- [ ] SSH強化設定

### 定期チェック項目
- [ ] セキュリティログの確認
- [ ] Fail2banの状況確認
- [ ] SSL証明書の有効期限確認
- [ ] ディスク使用量の確認
- [ ] システム更新の適用
- [ ] バックアップの実行

### 緊急時対応
- [ ] 異常なトラフィックの検出
- [ ] 不正アクセスの対応
- [ ] サービス停止時の復旧
- [ ] セキュリティインシデントの報告

## 監視コマンド

### Fail2ban状況確認
```bash
sudo fail2ban-client status
sudo fail2ban-client status postfix
sudo fail2ban-client status dovecot
```

### ファイアウォール状況
```bash
sudo ufw status verbose
sudo iptables -L -n -v
```

### メールサーバーログ
```bash
docker logs mailserver
docker exec mailserver tail -f /var/log/mail/mail.log
docker exec mailserver tail -f /var/log/mail/dovecot.log
```

### セキュリティ監視
```bash
./security/monitoring.sh
tail -f /var/log/mailserver-security.log
```

## トラブルシューティング

### 1. メールが送信できない場合

```bash
# SMTP接続確認
telnet mail.denzirou.com 587

# 認証設定確認
docker exec mailserver postconf | grep smtpd_sasl

# ログ確認
docker exec mailserver grep "authentication failed" /var/log/mail/mail.log
```

### 2. Fail2banでIPがBANされた場合

```bash
# BAN解除
sudo fail2ban-client set postfix unbanip [IP_ADDRESS]

# BAN状況確認
sudo fail2ban-client status postfix
```

### 3. SSL証明書の問題

```bash
# 証明書の再取得
docker exec certbot-mailserver certbot renew --force-renewal

# 証明書確認
docker exec mailserver openssl x509 -in /etc/letsencrypt/live/mail.denzirou.com/cert.pem -text
```

## セキュリティベストプラクティス

### 1. パスワード管理
- 強力なパスワードの使用
- 定期的なパスワード変更
- パスワード管理ツールの活用

### 2. アクセス制御
- 必要最小限の権限付与
- 定期的なアカウント監査
- 多要素認証の導入

### 3. ログ管理
- 定期的なログ確認
- ログの長期保存
- 異常なアクティビティの検出

### 4. システム更新
- 定期的なセキュリティ更新
- 脆弱性情報の監視
- テスト環境での事前検証

## 緊急連絡先

- **システム管理者**: admin@denzirou.com
- **セキュリティインシデント**: security@denzirou.com
- **技術サポート**: support@denzirou.com

## 参考資料

- [Docker Mailserver Documentation](https://docker-mailserver.github.io/docker-mailserver/edge/)
- [Fail2ban Manual](https://www.fail2ban.org/wiki/index.php/Manual)
- [Ubuntu Security Guide](https://ubuntu.com/security)
- [Mail Server Security Best Practices](https://www.cert.org/secure-coding/)