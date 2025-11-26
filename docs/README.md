# プロジェクト総合ドキュメント

## 📚 システム構成

### 🌐 Webシステム

| ドキュメント | 説明 | 対象者 |
|--------------|------|--------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | システム設計・アーキテクチャ概要 | 開発者・インフラ担当 |
| [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) | デプロイ手順・運用ガイド | 運用担当・開発者 |
| [DNS_SETUP_GUIDE.md](./DNS_SETUP_GUIDE.md) | DNS設定変更手順 | インフラ担当・管理者 |
| [POST_DNS_SETUP.md](./POST_DNS_SETUP.md) | DNS変更後のSSL設定手順 | インフラ担当・管理者 |

### 📧 メールシステム

| ドキュメント | 説明 | 対象者 |
|--------------|------|--------|
| [MAILSERVER_SETUP.md](./MAILSERVER_SETUP.md) | メールサーバー構築・設定ガイド | インフラ担当・管理者 |
| [MAILSERVER_SECURITY.md](./MAILSERVER_SECURITY.md) | セキュリティ強化・監視ガイド | セキュリティ担当・運用者 |
| [MAILSERVER_OPERATIONS.md](./MAILSERVER_OPERATIONS.md) | 日常運用・メンテナンスガイド | 運用担当・管理者 |
| [MAILSERVER_TROUBLESHOOTING.md](./MAILSERVER_TROUBLESHOOTING.md) | トラブルシューティングガイド | 全担当者 |

## 🎯 システム概要

### Webシステム構成

- **本番環境**: <https://denzirou.jp> (認証なし)
- **開発環境**: <https://dev.denzirou.jp> (Basic認証)

### メールシステム構成

- **メールサーバー**: mail.denzirou.com
- **SMTP**: 587 (STARTTLS), 465 (SSL)
- **IMAP**: 993 (SSL)
- **セキュリティ**: Fail2ban + Firewall + 監視

### 主要技術スタック

- **フレームワーク**: Next.js 14.2.31 (Web), docker-mailserver (Mail)
- **インフラ**: Docker + Docker Compose + Nginx
- **サーバー**: Sakura VPS (Ubuntu 22.04)
- **SSL**: Let's Encrypt (Certbot) - 自動更新
- **セキュリティ**: UFW + Fail2ban + Rspamd + ClamAV

## 🚀 クイックスタート

### Webシステム

```bash
# 1. 本番環境デプロイ
./deploy/deploy-production.sh

# 2. 開発環境デプロイ
./deploy/deploy-development.sh

# 3. 動作確認
curl -I https://denzirou.jp
curl -I -u dev:DevPass2025! https://dev.denzirou.jp
```

### メールシステム

```bash
# 1. メールサーバー起動確認
docker ps --filter name=mailserver

# 2. セキュリティ監視実行
/opt/mailserver/security/monitoring.sh

# 3. メールテスト送信
echo "Test" | docker exec -i mailserver sendmail -f contact@denzirou.com contact@denzirou.com
```

## 🔧 基本操作

### Webシステム操作

```bash
# デプロイ
./deploy/deploy-production.sh
./deploy/deploy-development.sh --force

# ヘルスチェック
curl -I https://denzirou.jp/proxy-health
curl -I -u dev:DevPass2025! https://dev.denzirou.jp/dev-info

# ログ確認
docker logs denzirou-prod-web
docker logs denzirou-dev-web
```

### メールシステム操作

```bash
# サービス管理
docker ps --filter name=mailserver
cd /opt/mailserver && docker compose -f docker-compose.mailserver.yml restart mailserver

# アカウント管理
docker exec mailserver setup email list
docker exec mailserver setup email add user@denzirou.com

# セキュリティ監視
/opt/mailserver/security/monitoring.sh
tail -f /opt/mailserver/mailserver-security.log
```

## 📊 システム状態確認

### ポート構成

| ポート | サービス | 環境 | 認証 |
|--------|----------|------|------|
| :80 | System Nginx | メインプロキシ | なし |
| :8080 | Production App | 本番環境 | なし |
| :8081 | Development App | 開発環境 | Basic |

### ドメイン構成

| ドメイン | 環境 | SSL | Basic認証 |
|----------|------|-----|-----------|
| denzirou.jp | 本番 | ✅ | ❌ |
| <www.denzirou.jp> | 本番 | ✅ | ❌ |
| dev.denzirou.jp | 開発 | ✅ | ✅ (dev/DevPass2025!) |

## 🛠️ トラブルシューティング

### よくある問題

1. **Basic認証が動作しない**
   - 開発環境のnginxコンテナが正常起動しているか確認
   - `.htpasswd_dev`ファイルの存在確認

2. **SSL証明書エラー**
   - DNS変更が完了しているか確認
   - `sudo certbot renew`で証明書更新

3. **コンテナ起動失敗**
   - ポート競合確認: `sudo netstat -tlnp | grep :8080`
   - ログ確認: `docker logs [container-name]`

### 緊急時連絡先

- DNS設定: ドメイン管理業者
- サーバー: Sakura VPS サポート
- アプリケーション: 開発チーム

## 📋 メンテナンス

### 定期作業

- **週次**: ログ確認、リソース確認
- **月次**: システムアップデート、証明書確認
- **四半期**: セキュリティ監査、バックアップテスト

### 監視項目

- [ ] サービス稼働状況
- [ ] SSL証明書有効期限
- [ ] ディスク使用量
- [ ] メモリ・CPU使用量
- [ ] セキュリティアラート

---

## サポート

問題が発生した場合は、該当するドキュメントを参照してください
