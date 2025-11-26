#!/bin/bash

# Email Management Script - メールアドレス作成・削除管理ツール
# Usage: ./email_manager.sh [command] [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAILSERVER_DIR="$SCRIPT_DIR/../docker/mailserver"
DOMAIN="denzirou.com"

# カラー出力定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ出力関数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Docker Mailserverが稼働しているか確認
check_mailserver() {
    if ! docker ps | grep -q "mailserver"; then
        log_error "Mailserver is not running. Please start it first."
        echo "Start command: docker compose -f docker-compose.mailserver.yml up -d"
        exit 1
    fi
}

# メールアカウント一覧表示
list_accounts() {
    log_info "Listing all email accounts..."
    echo ""
    
    if docker exec mailserver setup email list 2>/dev/null; then
        echo ""
        log_info "Mailbox directories:"
        docker exec mailserver ls -la /var/mail/$DOMAIN/ 2>/dev/null || log_warning "No mailbox directories found"
    else
        log_error "Failed to list email accounts"
        return 1
    fi
}

# メールアカウント作成
create_account() {
    local email="$1"
    local password="$2"
    local auto_password=false
    
    # 引数チェック
    if [[ -z "$email" ]]; then
        log_error "Email address is required"
        echo "Usage: $0 create <email@$DOMAIN> [password]"
        return 1
    fi
    
    # ドメイン確認
    if [[ "$email" != *"@$DOMAIN" ]]; then
        log_error "Email must be @$DOMAIN domain"
        return 1
    fi
    
    # パスワード生成
    if [[ -z "$password" ]]; then
        password=$(openssl rand -base64 12)
        auto_password=true
        log_info "Auto-generated password: $password"
    fi
    
    # ユーザー名抽出
    local username=$(echo "$email" | cut -d'@' -f1)
    
    log_info "Creating email account: $email"
    
    # アカウント作成
    if docker exec mailserver setup email add "$email" "$password" 2>/dev/null; then
        log_success "Email account created: $email"
        
        # メールボックス作成確認
        sleep 3
        if docker exec mailserver ls -la "/var/mail/$DOMAIN/$username" 2>/dev/null >/dev/null; then
            log_success "Mailbox directory created automatically"
        else
            log_warning "Mailbox directory not found, creating manually..."
            docker exec -u root mailserver mkdir -p "/var/mail/$DOMAIN/$username"
            docker exec -u root mailserver chown -R 5000:5000 "/var/mail/$DOMAIN/$username"
        fi
        
        # INBOX作成
        log_info "Creating INBOX..."
        if docker exec mailserver doveadm mailbox create -u "$email" INBOX 2>/dev/null; then
            log_success "INBOX created successfully"
        else
            log_warning "INBOX creation failed, will be created on first login"
        fi
        
        # パスワード情報表示
        echo ""
        echo "════════════════════════════════════════"
        echo "📧 Email Account Created Successfully!"
        echo "════════════════════════════════════════"
        echo "Email: $email"
        echo "Password: $password"
        if [[ "$auto_password" == true ]]; then
            echo "⚠️  Password was auto-generated. Please save it securely!"
        fi
        echo "════════════════════════════════════════"
        
    else
        log_error "Failed to create email account: $email"
        return 1
    fi
}

# メールアカウント削除
delete_account() {
    local email="$1"
    local confirm="$2"
    
    # 引数チェック
    if [[ -z "$email" ]]; then
        log_error "Email address is required"
        echo "Usage: $0 delete <email@$DOMAIN> [--confirm]"
        return 1
    fi
    
    # ドメイン確認
    if [[ "$email" != *"@$DOMAIN" ]]; then
        log_error "Email must be @$DOMAIN domain"
        return 1
    fi
    
    # ユーザー名抽出
    local username=$(echo "$email" | cut -d'@' -f1)
    
    # 確認プロンプト
    if [[ "$confirm" != "--confirm" ]]; then
        echo ""
        log_warning "This will permanently delete the email account and all its data!"
        echo "Email: $email"
        echo "Mailbox: /var/mail/$DOMAIN/$username"
        echo ""
        read -p "Are you sure you want to delete this account? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deletion cancelled"
            return 0
        fi
    fi
    
    log_info "Deleting email account: $email"
    
    # アカウント削除
    if docker exec mailserver setup email del "$email" 2>/dev/null; then
        log_success "Email account deleted from configuration"
    else
        log_error "Failed to delete email account from configuration"
        return 1
    fi
    
    # メールボックス削除
    if docker exec mailserver ls -la "/var/mail/$DOMAIN/$username" 2>/dev/null >/dev/null; then
        log_info "Removing mailbox directory..."
        docker exec -u root mailserver rm -rf "/var/mail/$DOMAIN/$username"
        log_success "Mailbox directory removed"
    else
        log_info "No mailbox directory found"
    fi
    
    log_success "Email account '$email' deleted completely"
}

# パスワード変更
change_password() {
    local email="$1"
    local new_password="$2"
    
    # 引数チェック
    if [[ -z "$email" ]]; then
        log_error "Email address is required"
        echo "Usage: $0 password <email@$DOMAIN> [new_password]"
        return 1
    fi
    
    # パスワード生成
    if [[ -z "$new_password" ]]; then
        new_password=$(openssl rand -base64 12)
        log_info "Auto-generated new password: $new_password"
    fi
    
    log_info "Changing password for: $email"
    
    # パスワード変更（削除→作成）
    if docker exec mailserver setup email del "$email" 2>/dev/null && \
       docker exec mailserver setup email add "$email" "$new_password" 2>/dev/null; then
        
        log_success "Password changed successfully"
        echo ""
        echo "════════════════════════════════════════"
        echo "🔑 Password Changed Successfully!"
        echo "════════════════════════════════════════"
        echo "Email: $email"
        echo "New Password: $new_password"
        echo "════════════════════════════════════════"
    else
        log_error "Failed to change password for: $email"
        return 1
    fi
}

# クイック作成（よく使われるアカウント）
quick_create() {
    local type="$1"
    
    case "$type" in
        "test")
            create_account "test$(date +%m%d)@$DOMAIN"
            ;;
        "temp")
            create_account "temp$(date +%H%M)@$DOMAIN"
            ;;
        "dev")
            create_account "dev$(whoami)@$DOMAIN"
            ;;
        *)
            log_error "Unknown quick create type: $type"
            echo "Available types: test, temp, dev"
            return 1
            ;;
    esac
}

# 使用方法表示
show_usage() {
    echo "Email Management Tool - Denzirou Mail Server"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list                           - List all email accounts"
    echo "  create <email> [password]      - Create new email account"
    echo "  delete <email> [--confirm]     - Delete email account"
    echo "  password <email> [new_pass]    - Change account password"
    echo "  quick <type>                   - Quick create (test|temp|dev)"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 create user@$DOMAIN"
    echo "  $0 create user@$DOMAIN mypassword"
    echo "  $0 delete user@$DOMAIN"
    echo "  $0 password user@$DOMAIN newpass"
    echo "  $0 quick test"
    echo ""
    echo "Domain: $DOMAIN"
}

# メイン処理
main() {
    local command="$1"
    shift || true
    
    # Docker Mailserver状態確認
    check_mailserver
    
    case "$command" in
        "list"|"ls")
            list_accounts
            ;;
        "create"|"add")
            create_account "$@"
            ;;
        "delete"|"del"|"rm")
            delete_account "$@"
            ;;
        "password"|"passwd")
            change_password "$@"
            ;;
        "quick")
            quick_create "$@"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        "")
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@"