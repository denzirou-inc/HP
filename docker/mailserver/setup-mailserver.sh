#!/bin/bash
# メールサーバーセットアップスクリプト
# Sakura VPS Ubuntu環境での初期セットアップ

set -e

echo "🚀 Docker Mailserver セットアップを開始します..."

# 現在のディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 必要なディレクトリを作成
echo "📁 必要なディレクトリを作成中..."
mkdir -p data/dms/mail-data
mkdir -p data/dms/mail-state
mkdir -p data/dms/mail-logs
mkdir -p data/dms/config
mkdir -p init-hooks
mkdir -p data/certbot/certs
mkdir -p data/certbot/www

# 権限設定
echo "🔐 ディレクトリ権限を設定中..."
sudo chown -R 5000:5000 data/dms/mail-data
sudo chown -R 5000:5000 data/dms/mail-state
sudo chown -R 5000:5000 data/dms/mail-logs

# 設定ファイルの作成
echo "📝 基本設定ファイルを作成中..."

# postfix-accounts.cf (メールアカウント設定)
cat > data/dms/config/postfix-accounts.cf << EOF
# メールアカウント設定
# フォーマット: user@domain.com|{PLAIN}password

# 基本アカウント
contact@denzirou.com|{PLAIN}$(openssl rand -base64 16)
admin@denzirou.com|{PLAIN}$(openssl rand -base64 16)
postmaster@denzirou.com|{PLAIN}$(openssl rand -base64 16)

# テスト用アカウント
test@denzirou.com|{PLAIN}testpass123
verify@denzirou.com|{PLAIN}verify123
EOF

# postfix-virtual.cf (エイリアス設定)
cat > data/dms/config/postfix-virtual.cf << EOF
# バーチャルエイリアス設定
@denzirou.com contact@denzirou.com
info@denzirou.com contact@denzirou.com
support@denzirou.com contact@denzirou.com
EOF

# postfix-main.cf (追加のPostfix設定)
cat > data/dms/config/postfix-main.cf << EOF
# 追加のPostfix設定
smtpd_banner = \$myhostname ESMTP Denzirou Mail Server
smtpd_helo_required = yes
smtpd_helo_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname

# メールボックス自動作成設定
virtual_create_maildirsize = yes
virtual_maildir_extended = yes
virtual_mailbox_limit_maps = hash:/etc/postfix/vmailbox_limit_maps
virtual_mailbox_limit_override = yes
virtual_maildir_limit_message = "The user you are trying to reach is over quota."
virtual_overquota_bounce = yes
EOF

# dovecot.cf (Dovecot設定)
cat > data/dms/config/dovecot.cf << EOF
# Dovecot追加設定
mail_max_userip_connections = 50
mail_plugins = \$mail_plugins quota
EOF

echo "✅ 設定ファイルを作成しました"

# 初期化フックスクリプトをコピー
echo "🔧 初期化フックを設定中..."
if [[ -f "01-auto-create-mailboxes.sh" ]]; then
    cp "01-auto-create-mailboxes.sh" "init-hooks/"
    chmod +x "init-hooks/01-auto-create-mailboxes.sh"
fi
if [[ -f "02-watch-accounts-changes.sh" ]]; then
    cp "02-watch-accounts-changes.sh" "init-hooks/"
    chmod +x "init-hooks/02-watch-accounts-changes.sh"
fi

# Docker Composeでサービスを起動
echo "🐳 Docker Mailserverを起動中..."
docker-compose -f docker-compose.mailserver.yml up -d

echo "⏳ サービスの起動を待機中..."
sleep 30

# サービスの状態確認
echo "📊 サービス状態を確認中..."
docker-compose -f docker-compose.mailserver.yml ps

echo ""
echo "🎉 Enhanced メールサーバーのセットアップが完了しました！"
echo ""
echo "✅ 新機能:"
echo "   - 自動メールボックス作成"
echo "   - 初期化コンテナによる事前準備" 
echo "   - 設定変更監視"
echo "   - 標準メールフォルダ自動作成"
echo ""
echo "📋 次の手順を実行してください："
echo "1. DNSレコードを設定"
echo "   - A: mail.denzirou.com -> サーバーIP"
echo "   - MX: denzirou.com -> mail.denzirou.com (priority 10)"
echo "   - TXT (SPF): v=spf1 mx ~all"
echo "   - TXT (DMARC): v=DMARC1; p=quarantine; rua=mailto:admin@denzirou.com"
echo ""
echo "2. DKIM設定"
echo "   docker exec mailserver setup config dkim"
echo ""
echo "3. SSL証明書の取得"
echo "   Let's Encryptが自動で証明書を取得します"
echo ""
echo "4. メールアカウントのパスワード確認"
echo "   cat data/dms/config/postfix-accounts.cf"
echo ""
echo "5. ファイアウォール設定（必要に応じて）"
echo "   sudo ufw allow 25/tcp"
echo "   sudo ufw allow 465/tcp"
echo "   sudo ufw allow 587/tcp"
echo "   sudo ufw allow 993/tcp"
echo ""
echo "🔍 ログ確認："
echo "   docker-compose -f docker-compose.mailserver.yml logs -f mailserver"