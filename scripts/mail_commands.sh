#!/bin/bash

# Simple Mail Commands - サーバー直接操作用
# Usage: source this file or copy commands for direct use

DOMAIN="denzirou.com"

# メールアカウント一覧
alias mail-list='docker exec mailserver setup email list && echo "" && echo "📁 Mailbox directories:" && docker exec mailserver ls -la /var/mail/denzirou.com/'

# メールアカウント作成
mail-create() {
    local email="$1"
    local password="$2"
    
    if [[ -z "$email" ]]; then
        echo "Usage: mail-create user@denzirou.com [password]"
        echo "Example: mail-create test@denzirou.com"
        return 1
    fi
    
    if [[ -z "$password" ]]; then
        password=$(openssl rand -base64 12)
        echo "Auto-generated password: $password"
    fi
    
    echo "Creating: $email"
    docker exec mailserver setup email add "$email" "$password" && \
    sleep 2 && \
    docker exec mailserver doveadm mailbox create -u "$email" INBOX && \
    echo "✅ Created: $email (Password: $password)"
}

# メールアカウント削除
mail-delete() {
    local email="$1"
    
    if [[ -z "$email" ]]; then
        echo "Usage: mail-delete user@denzirou.com"
        return 1
    fi
    
    local username=$(echo "$email" | cut -d'@' -f1)
    
    echo "⚠️  Deleting: $email"
    read -p "Type 'yes' to confirm: " confirm
    if [[ "$confirm" == "yes" ]]; then
        docker exec mailserver setup email del "$email" && \
        docker exec -u root mailserver rm -rf "/var/mail/$DOMAIN/$username" && \
        echo "✅ Deleted: $email"
    else
        echo "Cancelled"
    fi
}

# パスワード変更
mail-password() {
    local email="$1"
    local new_password="$2"
    
    if [[ -z "$email" ]]; then
        echo "Usage: mail-password user@denzirou.com [new_password]"
        return 1
    fi
    
    if [[ -z "$new_password" ]]; then
        new_password=$(openssl rand -base64 12)
        echo "Auto-generated password: $new_password"
    fi
    
    echo "Changing password for: $email"
    docker exec mailserver setup email del "$email" && \
    docker exec mailserver setup email add "$email" "$new_password" && \
    echo "✅ Password changed: $email (New password: $new_password)"
}

# テストアカウント作成
mail-test() {
    mail-create "test$(date +%m%d)@$DOMAIN"
}

# 一時アカウント作成
mail-temp() {
    mail-create "temp$(date +%H%M)@$DOMAIN"
}

# メール送信テスト
mail-send-test() {
    local to_email="$1"
    local subject="${2:-Test from server}"
    
    if [[ -z "$to_email" ]]; then
        echo "Usage: mail-send-test user@denzirou.com [subject]"
        return 1
    fi
    
    echo "Test email sent at $(date)" | docker exec -i mailserver mail -s "$subject" "$to_email"
    echo "✅ Test email sent to: $to_email"
}

# 受信確認
mail-check() {
    local email="$1"
    
    if [[ -z "$email" ]]; then
        echo "Usage: mail-check user@denzirou.com"
        return 1
    fi
    
    docker exec mailserver doveadm mailbox status -u "$email" messages INBOX
}

# ヘルプ表示
mail-help() {
    echo "📧 Mail Commands for Denzirou Server"
    echo ""
    echo "Commands:"
    echo "  mail-list                    - List all accounts"
    echo "  mail-create user@$DOMAIN     - Create account"
    echo "  mail-delete user@$DOMAIN     - Delete account" 
    echo "  mail-password user@$DOMAIN   - Change password"
    echo "  mail-test                    - Create test account"
    echo "  mail-temp                    - Create temp account"
    echo "  mail-send-test user@$DOMAIN  - Send test email"
    echo "  mail-check user@$DOMAIN      - Check inbox"
    echo "  mail-help                    - Show this help"
    echo ""
    echo "Examples:"
    echo "  mail-create demo@$DOMAIN"
    echo "  mail-send-test demo@$DOMAIN"
    echo "  mail-check demo@$DOMAIN"
    echo "  mail-delete demo@$DOMAIN"
}

echo "📧 Mail commands loaded! Type 'mail-help' for usage."