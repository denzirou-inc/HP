#!/bin/bash

# Docker Mailserver 自動初期化スクリプト
# メールアカウント作成時の自動メールボックス作成
# このスクリプトはDocker Mailserver起動時に実行されます

set -e

echo "🔧 [INIT] Auto mailbox creation hook starting..."

# 設定ファイルが存在するかチェック
if [[ ! -f /tmp/docker-mailserver/postfix-accounts.cf ]]; then
    echo "ℹ️  [INIT] No accounts file found, skipping mailbox creation"
    exit 0
fi

# postfix-accounts.cfからメールアカウントを読み取り
echo "📋 [INIT] Reading mail accounts from configuration..."
while IFS='|' read -r email encrypted_password; do
    # コメント行や空行をスキップ
    if [[ "$email" =~ ^#.*$ ]] || [[ -z "$email" ]]; then
        continue
    fi
    
    # メールアドレスの妥当性チェック
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        # ドメインとユーザー名を抽出
        domain=$(echo "$email" | cut -d'@' -f2)
        user=$(echo "$email" | cut -d'@' -f1)
        
        echo "📁 [INIT] Creating mailbox structure for: $email"
        
        # メールディレクトリ作成
        mkdir -p "/var/mail/$domain/$user"
        
        # 権限設定（vmail user:group = 5000:5000）
        chown -R 5000:5000 "/var/mail/$domain"
        chmod -R 755 "/var/mail/$domain"
        
        echo "✅ [INIT] Mailbox created for: $email"
    else
        echo "⚠️  [INIT] Invalid email format, skipping: $email"
    fi
done < /tmp/docker-mailserver/postfix-accounts.cf

# Dovecot設定でmaildir自動作成を有効化
echo "🐦 [INIT] Configuring Dovecot for mailbox auto-creation..."

# custom dovecot configuration
cat >> /etc/dovecot/conf.d/99-custom-mailbox.conf << 'DOVECOT_EOF'
# 自動メールボックス作成設定
namespace inbox {
  mailbox "INBOX" {
    auto = create
    special_use = \Inbox
  }
  mailbox "Drafts" {
    auto = create
    special_use = \Drafts
  }
  mailbox "Sent" {
    auto = create
    special_use = \Sent
  }
  mailbox "Trash" {
    auto = create
    special_use = \Trash
  }
  mailbox "Junk" {
    auto = create
    special_use = \Junk
  }
}

# メールボックス自動作成設定
mail_plugins = $mail_plugins autocreate

plugin {
  autocreate = INBOX
  autocreate2 = Sent
  autocreate3 = Drafts  
  autocreate4 = Trash
  autocreate5 = Junk
  autosubscribe = INBOX
  autosubscribe2 = Sent
  autosubscribe3 = Drafts
  autosubscribe4 = Trash
  autosubscribe5 = Junk
}
DOVECOT_EOF

echo "✅ [INIT] Auto mailbox creation hook completed successfully!"

# 成功をログに記録
echo "$(date): Auto mailbox creation completed for $(wc -l < /tmp/docker-mailserver/postfix-accounts.cf) accounts" >> /var/log/mail/init-hooks.log