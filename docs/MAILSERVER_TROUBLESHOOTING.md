# メールサーバー トラブルシューティングガイド

## 🚨 緊急時対応フローチャート

```text
メール問題発生
      ↓
[サービス稼働中？] → No → サービス再起動 → 解決？ → Yes → 完了
      ↓ Yes                      ↓ No
[送信・受信どちら？]              ↓
      ↓                         原因調査
[送信問題] [受信問題]              ↓
      ↓         ↓               エキスパート対応
   送信調査   受信調査
      ↓         ↓
    設定修正   設定修正
      ↓         ↓
      完了      完了
```

## 🔧 問題診断ツール

### 基本診断コマンド

```bash
# 1. サービス状態確認
docker ps --filter name=mailserver
docker exec mailserver supervisorctl status

# 2. ポート稼働確認
docker exec mailserver ss -tlnp | grep ':25\|:587\|:465\|:993'

# 3. 基本接続テスト
telnet mail.denzirou.com 25
telnet mail.denzirou.com 587
telnet mail.denzirou.com 993

# 4. DNS確認
dig MX denzirou.com
dig A mail.denzirou.com
```

### ログ分析スクリプト

```bash
#!/bin/bash
# メールサーバー診断スクリプト

echo "=== メールサーバー診断開始 ==="

# サービス状態
echo "1. サービス状態:"
docker ps --filter name=mailserver --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# ポート稼働状況
echo -e "\n2. ポート稼働状況:"
docker exec mailserver ss -tlnp | grep ':25\|:587\|:465\|:993'

# 最新エラー
echo -e "\n3. 最新エラー (過去1時間):"
docker exec mailserver grep "$(date '+%Y-%m-%d %H')" \
  /var/log/mail/mail.log | grep -i error | tail -5

# 認証失敗
echo -e "\n4. 認証失敗 (過去1時間):"
docker exec mailserver grep "$(date '+%Y-%m-%d %H')" \
  /var/log/mail/mail.log | grep -i "authentication failed" | wc -l

# ディスク使用量
echo -e "\n5. ディスク使用量:"
docker exec mailserver df -h /var/mail

# メール送信キュー
echo -e "\n6. 送信キュー:"
docker exec mailserver postqueue -p | tail -1

echo "=== 診断完了 ==="
```

## 📧 送信問題のトラブルシューティング

### 症状: メール送信できない

#### 段階1: 基本確認

```bash
# SMTP接続テスト
telnet mail.denzirou.com 587

# 期待する応答: "220 mail.denzirou.com ESMTP"
# 応答なし → ファイアウォール・ポート問題
# エラー応答 → 設定問題
```

#### 段階2: 認証確認

```bash
# 認証テスト
docker exec mailserver doveadm auth test contact@denzirou.com

# 成功例: "passdb lookup: user=contact@denzirou.com auth succeeded"
# 失敗例: "auth failed"
```

#### 段階3: 設定確認

```bash
# Postfix設定確認
docker exec mailserver postconf | grep smtpd_sasl

# 送信ログ確認
docker exec mailserver grep "NOQUEUE\|reject" \
  /var/log/mail/mail.log | tail -10
```

### よくある送信問題と解決法

| 症状 | 原因 | 解決法 |
|------|------|--------|
| `Connection refused` | ファイアウォール | `sudo ufw allow 587/tcp` |
| `Authentication failed` | 認証情報エラー | パスワード・ユーザー名確認 |
| `Relay access denied` | 認証なし送信 | SMTP認証設定確認 |
| `Certificate error` | SSL証明書問題 | 証明書更新・設定確認 |
| `Rate limit exceeded` | 送信制限超過 | レート制限設定見直し |

## 📨 受信問題のトラブルシューティング

### 症状: メール受信できない

#### 段階1: DNS確認

```bash
# MXレコード確認
dig MX denzirou.com

# 期待する応答: "10 mail.denzirou.com."
# 応答なし → DNS設定問題
```

#### 段階2: IMAP接続確認

```bash
# IMAP接続テスト
openssl s_client -connect mail.denzirou.com:993

# SSL接続成功 → "Verify return code: 0 (ok)"
# 失敗 → SSL証明書問題
```

#### 段階3: メールボックス確認

```bash
# メールボックス一覧
docker exec mailserver doveadm mailbox list -u contact@denzirou.com

# メール配信ログ確認
docker exec mailserver grep "delivered to" \
  /var/log/mail/mail.log | tail -5
```

### よくある受信問題と解決法

| 症状 | 原因 | 解決法 |
|------|------|--------|
| `No route to host` | ファイアウォール | `sudo ufw allow 993/tcp` |
| `SSL handshake failed` | SSL証明書問題 | 証明書確認・更新 |
| `Mailbox full` | 容量超過 | クォータ拡張・古いメール削除 |
| `User unknown` | アカウント存在しない | アカウント作成確認 |
| `Permission denied` | 権限問題 | `chown 5000:5000 /var/mail/` |

## 🔒 セキュリティ関連問題

### Fail2ban関連問題

```bash
# Fail2ban状態確認
docker exec mailserver fail2ban-client status

# 特定jail状態確認
docker exec mailserver fail2ban-client status postfix

# BAN解除
docker exec mailserver fail2ban-client unban <IPアドレス>

# ログ確認
docker exec mailserver tail -f /var/log/fail2ban.log
```

### SSL/TLS証明書問題

```bash
# 証明書確認
sudo openssl x509 -text -in /etc/letsencrypt/live/mail.denzirou.com/fullchain.pem

# 有効期限確認
sudo openssl x509 -enddate -noout \
  -in /etc/letsencrypt/live/mail.denzirou.com/fullchain.pem

# 手動更新
sudo certbot renew --force-renewal -d mail.denzirou.com

# サービス再起動で反映
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml \
  restart mailserver
```

## ⚡ 性能問題のトラブルシューティング

### 症状: メール送受信が遅い

#### 段階1: リソース確認

```bash
# CPU・メモリ使用量
docker stats mailserver --no-stream

# ディスクI/O確認
docker exec mailserver iostat -x 1 5

# ネットワーク確認
docker exec mailserver ss -i
```

#### 段階2: キュー確認

```bash
# 送信キュー確認
docker exec mailserver postqueue -p

# キューサイズが大きい場合の対処
docker exec mailserver postqueue -f  # フラッシュ
docker exec mailserver postsuper -d ALL deferred  # 遅延メール削除
```

#### 段階3: チューニング

```bash
# Postfix同時接続数調整
docker exec mailserver postconf -e "default_process_limit = 200"

# Dovecot接続数調整  
echo "default_client_limit = 2000" \
  >> /opt/mailserver/security/dovecot-security.cf

# 設定反映
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml \
  restart mailserver
```

## 🗃️ データ関連問題

### 症状: メールデータ消失・破損

#### 段階1: バックアップ確認

```bash
# バックアップ存在確認
ls -la /backup/mailserver/

# 最新バックアップ確認
ls -la /backup/mailserver/ | tail -5
```

#### 段階2: データ整合性確認

```bash
# メールボックス整合性チェック
docker exec mailserver doveadm force-resync -u contact@denzirou.com INBOX

# インデックス再構築
docker exec mailserver doveadm index -u contact@denzirou.com INBOX
```

#### 段階3: 復旧手順

```bash
# 1. サービス停止
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml down

# 2. データ復旧
tar -xzf /backup/mailserver/YYYYMMDD_HHMMSS/mailserver-data.tar.gz \
  -C /

# 3. 権限修正
sudo chown -R 5000:5000 /opt/mailserver/data/dms/mail-data/

# 4. サービス開始
docker compose -f docker-compose.mailserver.yml up -d
```

## 🔍 高度な診断技術

### パケットキャプチャ

```bash
# SMTP通信キャプチャ
sudo tcpdump -i any -w smtp-capture.pcap port 587

# IMAP通信キャプチャ
sudo tcpdump -i any -w imap-capture.pcap port 993

# 解析
wireshark smtp-capture.pcap
```

### デバッグモード

```bash
# Postfixデバッグ有効化
docker exec mailserver postconf \
  -e "debug_peer_list = <テスト送信者IP>"
docker exec mailserver postfix reload

# Dovecotデバッグ有効化
echo "auth_debug = yes" \
  >> /opt/mailserver/security/dovecot-security.cf
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml \
  restart mailserver
```

## 📋 トラブルチェックリスト

### 送信問題チェックリスト

- [ ] ファイアウォールポート開放 (25, 587, 465)
- [ ] DNS MXレコード設定
- [ ] SSL証明書有効性
- [ ] SMTP認証設定
- [ ] レート制限設定
- [ ] スパムフィルタ設定
- [ ] 送信キュー状態

### 受信問題チェックリスト

- [ ] IMAP/POP3ポート開放 (993, 995)
- [ ] SSL証明書有効性
- [ ] メールボックス存在確認
- [ ] 容量制限確認
- [ ] 権限設定確認
- [ ] DNS逆引き設定

### セキュリティ問題チェックリスト

- [ ] Fail2ban動作状況
- [ ] SSL/TLS設定
- [ ] 認証設定
- [ ] ファイアウォール設定
- [ ] ログ監視設定
- [ ] アップデート状況

## 🆘 エスカレーション

### サポート依頼時の情報収集

```bash
# システム情報収集スクリプト
#!/bin/bash
echo "=== システム情報 ==="
docker --version
docker compose version

echo -e "\n=== メールサーバー情報 ==="
docker ps --filter name=mailserver
docker exec mailserver postconf mail_version
docker exec mailserver dovecot --version

echo -e "\n=== 最新ログ ==="
docker logs mailserver --tail 50

echo -e "\n=== 設定情報 ==="
docker exec mailserver postconf -n
```

### 緊急連絡先

- システム管理者: <admin@denzirou.com>
- セキュリティ担当者: <security@denzirou.com>
- ベンダーサポート: [契約サポート窓口]

---

**問題解決後は必ず根本原因を文書化し、再発防止策を検討してください。**
