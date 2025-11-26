# メールサーバー運用ガイド

## 🔧 日常運用

### サービス状態確認

```bash
# メールサーバー全体の状態確認
docker ps --filter name=mailserver

# メールサーバーヘルスチェック
docker exec mailserver ss -tlnp | grep ':25\|:587\|:465\|:993'

# ディスク使用量確認
docker exec mailserver df -h /var/mail

# メモリ使用量確認
docker stats mailserver --no-stream
```

### ログ監視

```bash
# リアルタイムメールログ監視
docker exec mailserver tail -f /var/log/mail/mail.log

# 認証関連ログ
docker exec mailserver grep "authentication" /var/log/mail/mail.log | tail -20

# エラーログ確認
docker exec mailserver tail -f /var/log/mail/mail.err

# セキュリティ監視ログ
tail -f /opt/mailserver/mailserver-security.log
```

## 📧 メールアカウント管理

### アカウント操作

```bash
# 既存アカウント一覧表示
docker exec mailserver setup email list

# 新規アカウント作成
docker exec mailserver setup email add user@denzirou.com

# アカウント削除
docker exec mailserver setup email del user@denzirou.com

# パスワード変更
docker exec mailserver setup email update user@denzirou.com
```

### クォータ管理

```bash
# 全アカウントのクォータ確認
docker exec mailserver setup quota list

# 特定アカウントのクォータ設定
docker exec mailserver setup quota set user@denzirou.com 2G

# 使用量確認
docker exec mailserver du -sh /var/mail/denzirou.com/user/
```

### エイリアス管理

```bash
# エイリアス設定確認
docker exec mailserver cat /tmp/docker-mailserver/postfix-virtual.cf

# エイリアス追加（手動編集後）
docker exec mailserver postmap /tmp/docker-mailserver/postfix-virtual.cf
docker exec mailserver postfix reload
```

## 🔄 メンテナンス作業

### 定期メンテナンス

```bash
# メールキュー確認
docker exec mailserver postqueue -p

# メールキュー削除（必要時）
docker exec mailserver postsuper -d ALL

# ログローテーション手動実行
docker exec mailserver logrotate -f /etc/logrotate.d/rsyslog

# テンポラリファイル清掃
docker exec mailserver find /tmp -type f -mtime +7 -delete
```

### データベース最適化

```bash
# Postfix設定再読み込み
docker exec mailserver postfix reload

# Dovecot設定再読み込み
docker exec mailserver doveadm reload

# Rspamd統計更新
docker exec mailserver rspamadm statconvert
```

## 📊 性能監視

### 性能メトリクス確認

```bash
# メール送受信統計
docker exec mailserver pflogsumm -d today /var/log/mail/mail.log

# 接続統計
docker exec mailserver ss -s

# Rspamdスパム検出統計
docker exec mailserver rspamadm stat

# Dovecot接続統計
docker exec mailserver doveadm stats dump
```

### アラート閾値

| メトリクス | 警告 | 緊急 | アクション |
|-----------|------|------|-----------|
| CPU使用率 | 70% | 90% | プロセス調査・最適化 |
| メモリ使用率 | 80% | 95% | メモリリーク調査 |
| ディスク使用率 | 70% | 90% | ログローテーション・クリーンアップ |
| 認証失敗率 | 50回/時 | 100回/時 | セキュリティ調査 |
| メール送信遅延 | 5分 | 15分 | キュー調査・設定確認 |

## 🔧 トラブルシューティング

### よくある問題と対処法

#### 1. メール送信できない

**症状チェック:**

```bash
# SMTP接続確認
telnet mail.denzirou.com 587

# 認証テスト
docker exec mailserver doveadm auth test user@denzirou.com

# 送信キュー確認
docker exec mailserver postqueue -p
```

**対処手順:**

1. 認証情報の確認
2. ファイアウォール設定確認
3. SSL証明書の確認
4. レート制限の確認

#### 2. メール受信できない

**症状チェック:**

```bash
# IMAP接続確認
telnet mail.denzirou.com 993

# メールボックス確認
docker exec mailserver doveadm mailbox list -u user@denzirou.com

# 配信ログ確認
docker exec mailserver grep "delivered" /var/log/mail/mail.log
```

**対処手順:**

1. DNS MXレコードの確認
2. ポート993の開放確認
3. SSL証明書の確認
4. ディスク容量の確認

#### 3. スパムフィルタリング問題

**症状チェック:**

```bash
# Rspamd統計確認
docker exec mailserver rspamadm stat

# スパムルール確認
docker exec mailserver rspamadm configtest

# 学習データ確認
docker exec mailserver rspamadm stat --classifier=bayes
```

**対処手順:**

1. スパム学習データの更新
2. ルール設定の調整
3. ホワイトリスト・ブラックリストの確認

## 💾 バックアップ・復旧

### バックアップ対象

```bash
# 設定ファイル
/opt/mailserver/data/dms/config/
/opt/mailserver/docker-compose.mailserver.yml
/opt/mailserver/security/

# メールデータ
/opt/mailserver/data/dms/mail-data/
/opt/mailserver/data/dms/mail-state/

# ログファイル
/opt/mailserver/data/dms/mail-logs/
```

### バックアップスクリプト

```bash
#!/bin/bash
# メールサーバーバックアップスクリプト

BACKUP_DIR="/backup/mailserver/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 設定とデータのバックアップ
tar -czf "$BACKUP_DIR/mailserver-config.tar.gz" /opt/mailserver/
tar -czf "$BACKUP_DIR/mailserver-data.tar.gz" /opt/mailserver/data/

# データベース・統計のバックアップ
docker exec mailserver rspamadm dump > "$BACKUP_DIR/rspamd-dump.sql"

# 古いバックアップ削除（30日以上）
find /backup/mailserver/ -type d -mtime +30 -exec rm -rf {} +

echo "バックアップ完了: $BACKUP_DIR"
```

### 復旧手順

```bash
# 1. メールサーバー停止
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml down

# 2. バックアップから復旧
tar -xzf /backup/mailserver/YYYYMMDD_HHMMSS/mailserver-data.tar.gz -C /

# 3. 権限修正
sudo chown -R 5000:5000 /opt/mailserver/data/dms/mail-data/

# 4. サービス再開
docker compose -f docker-compose.mailserver.yml up -d

# 5. 動作確認
docker logs mailserver --tail 20
```

## 📈 定期メンテナンススケジュール

### 日次作業（自動化推奨）

- [ ] セキュリティ監視スクリプト実行
- [ ] ディスク使用量チェック
- [ ] エラーログ確認
- [ ] バックアップ実行

### 週次作業

- [ ] メール送受信統計確認
- [ ] Fail2banログ分析
- [ ] スパムフィルタ精度確認
- [ ] 性能メトリクス確認

### 月次作業

- [ ] SSL証明書有効期限確認
- [ ] システムアップデート適用
- [ ] ログファイルアーカイブ
- [ ] セキュリティ設定見直し
- [ ] 復旧テスト実施

### 四半期作業

- [ ] 全面的な設定見直し
- [ ] 災害復旧計画更新
- [ ] セキュリティ監査実施
- [ ] 性能チューニング

## 🚨 緊急時対応

### サービス停止時の対応

```bash
# 1. 状況確認
docker ps -a --filter name=mailserver
docker logs mailserver --tail 50

# 2. サービス再起動
cd /opt/mailserver
docker compose -f docker-compose.mailserver.yml restart mailserver

# 3. 根本原因調査
# ディスク容量、メモリ、ログエラーを確認

# 4. 必要に応じてロールバック
# 直前のバックアップから復旧
```

### セキュリティインシデント時の対応

```bash
# 1. 即座にサービス隔離
sudo ufw deny 25/tcp
sudo ufw deny 587/tcp

# 2. ログ保全
cp -r /opt/mailserver/data/dms/mail-logs/ /incident/logs/

# 3. 影響範囲調査
docker exec mailserver grep "$(date +%Y-%m-%d)" /var/log/mail/mail.log

# 4. 復旧計画策定
# セキュリティパッチ適用、設定変更、アカウント無効化等
```

---

**この運用ガイドに従って安定的なメールサーバー運用を実現してください。**
