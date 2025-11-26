#!/bin/bash
# メール証明書更新時にメールサーバーを再起動

# 更新された証明書のドメインを確認
if [[ "$RENEWED_DOMAINS" == *"mail.denzirou.com"* ]]; then
    echo "$(date): mail.denzirou.com 証明書が更新されました。メールサーバーを再起動します..."

    # メールサーバーコンテナを再起動
    /usr/bin/docker restart mailserver

    # ログに記録
    echo "$(date): メールサーバーの再起動が完了しました" >> /var/log/mailserver-cert-renewal.log

    # 新しい証明書の有効期限を確認
    NEW_EXPIRY=$(openssl x509 -in /etc/letsencrypt/live/mail.denzirou.com/cert.pem -noout -enddate)
    echo "$(date): 新しい証明書の有効期限: $NEW_EXPIRY" >> /var/log/mailserver-cert-renewal.log
fi
