# Certbot 更新フックスクリプト

このディレクトリには、SSL証明書の自動更新時に実行されるフックスクリプトが含まれています。

## ファイル

### restart-mailserver.sh

**目的**: mail.denzirou.com の SSL証明書が更新された際に、メールサーバーを自動的に再起動します。

**配置場所**: `/etc/letsencrypt/renewal-hooks/deploy/restart-mailserver.sh`

**動作**:
1. `RENEWED_DOMAINS` 環境変数をチェックし、`mail.denzirou.com` が含まれているか確認
2. 含まれている場合、Dockerのmailserverコンテナを再起動
3. 再起動のログを `/var/log/mailserver-cert-renewal.log` に記録
4. 新しい証明書の有効期限をログに記録

**実行タイミング**: certbot が証明書を更新した直後（deploy フック）

**ログファイル**: `/var/log/mailserver-cert-renewal.log`

## デプロイ

このスクリプトは、`deploy/deploy-production.sh` の実行時に自動的に本番環境にデプロイされます。

手動でデプロイする場合：
```bash
# 本番環境にコピー
scp scripts/certbot/restart-mailserver.sh admin@denzirou.com:/tmp/
ssh admin:denzirou_web 'sudo cp /tmp/restart-mailserver.sh /etc/letsencrypt/renewal-hooks/deploy/ && sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/restart-mailserver.sh'
```

## テスト

スクリプトのテスト:
```bash
ssh admin:denzirou_web 'sudo RENEWED_DOMAINS="mail.denzirou.com" bash /etc/letsencrypt/renewal-hooks/deploy/restart-mailserver.sh'
```

ログの確認:
```bash
ssh admin:denzirou_web 'sudo cat /var/log/mailserver-cert-renewal.log'
```

## 関連情報

- Certbot 自動更新スケジュール: 毎日午前3時（ランダム遅延最大30分）
- タイマー設定: `/etc/systemd/system/certbot.timer.d/override.conf`
- メールサーバー証明書マウント:
  - privkey: `/etc/letsencrypt/live/mail.denzirou.com/privkey.pem` → コンテナ内 `/etc/ssl/private/mailserver.key`
  - fullchain: `/etc/letsencrypt/live/mail.denzirou.com/fullchain.pem` → コンテナ内 `/etc/ssl/certs/mailserver.crt`
