#!/bin/bash

# Email Admin Interface - インタラクティブメール管理ツール
# 対話形式でメールアカウントを管理

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMAIL_MANAGER="$SCRIPT_DIR/email_manager.sh"
DOMAIN="denzirou.com"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 画面クリア
clear_screen() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}              📧 Denzirou Email Administration Panel 📧              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# メインメニュー表示
show_main_menu() {
    echo -e "${CYAN}🎯 Main Menu${NC}"
    echo ""
    echo "  1) 📋 List all email accounts"
    echo "  2) ➕ Create new email account"
    echo "  3) ❌ Delete email account"
    echo "  4) 🔑 Change password"
    echo "  5) 🧪 Quick create test account"
    echo "  6) ⏰ Quick create temporary account"
    echo "  7) 🔍 Search accounts"
    echo "  8) 📊 Account statistics"
    echo "  9) 🚀 Bulk operations"
    echo "  0) 🚪 Exit"
    echo ""
    echo -e "${PURPLE}Domain: $DOMAIN${NC}"
    echo ""
}

# プロンプト表示
prompt() {
    echo -ne "${GREEN}➤ ${NC}"
}

# Enterキー待ち
wait_enter() {
    echo ""
    echo -ne "${YELLOW}Press Enter to continue...${NC}"
    read
}

# アカウント一覧表示
list_accounts_interactive() {
    clear_screen
    echo -e "${CYAN}📋 Email Accounts List${NC}"
    echo ""
    
    if $EMAIL_MANAGER list; then
        echo ""
        echo -e "${GREEN}✅ Account list displayed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to list accounts${NC}"
    fi
    
    wait_enter
}

# アカウント作成
create_account_interactive() {
    clear_screen
    echo -e "${CYAN}➕ Create New Email Account${NC}"
    echo ""
    
    # メールアドレス入力
    echo -e "${YELLOW}Enter email address (without @$DOMAIN):${NC}"
    prompt
    read -r username
    
    if [[ -z "$username" ]]; then
        echo -e "${RED}❌ Username cannot be empty${NC}"
        wait_enter
        return
    fi
    
    local email="${username}@${DOMAIN}"
    
    # パスワード選択
    echo ""
    echo -e "${YELLOW}Password option:${NC}"
    echo "  1) Auto-generate secure password"
    echo "  2) Enter custom password"
    echo ""
    prompt
    read -r pass_option
    
    local password=""
    case "$pass_option" in
        "1")
            echo -e "${GREEN}Auto-generating password...${NC}"
            ;;
        "2")
            echo -e "${YELLOW}Enter password:${NC}"
            prompt
            read -r password
            ;;
        *)
            echo -e "${RED}Invalid option. Auto-generating password...${NC}"
            ;;
    esac
    
    # アカウント作成実行
    echo ""
    echo -e "${BLUE}Creating account: $email${NC}"
    
    if [[ -n "$password" ]]; then
        $EMAIL_MANAGER create "$email" "$password"
    else
        $EMAIL_MANAGER create "$email"
    fi
    
    wait_enter
}

# アカウント削除
delete_account_interactive() {
    clear_screen
    echo -e "${CYAN}❌ Delete Email Account${NC}"
    echo ""
    
    # 既存アカウント表示
    echo -e "${YELLOW}Current accounts:${NC}"
    $EMAIL_MANAGER list | grep -E "^\*" | head -10 || echo "No accounts found"
    
    echo ""
    echo -e "${YELLOW}Enter email address to delete:${NC}"
    prompt
    read -r email
    
    if [[ -z "$email" ]]; then
        echo -e "${RED}❌ Email address cannot be empty${NC}"
        wait_enter
        return
    fi
    
    # ドメイン自動補完
    if [[ "$email" != *"@"* ]]; then
        email="${email}@${DOMAIN}"
    fi
    
    echo ""
    echo -e "${RED}⚠️  WARNING: This will permanently delete:${NC}"
    echo -e "${RED}   - Account: $email${NC}"
    echo -e "${RED}   - All emails in the account${NC}"
    echo -e "${RED}   - Mailbox directory${NC}"
    echo ""
    echo -e "${YELLOW}Type 'DELETE' to confirm:${NC}"
    prompt
    read -r confirmation
    
    if [[ "$confirmation" == "DELETE" ]]; then
        echo ""
        echo -e "${BLUE}Deleting account: $email${NC}"
        $EMAIL_MANAGER delete "$email" --confirm
    else
        echo -e "${GREEN}Deletion cancelled${NC}"
    fi
    
    wait_enter
}

# パスワード変更
change_password_interactive() {
    clear_screen
    echo -e "${CYAN}🔑 Change Account Password${NC}"
    echo ""
    
    # 既存アカウント表示
    echo -e "${YELLOW}Current accounts:${NC}"
    $EMAIL_MANAGER list | grep -E "^\*" | head -10 || echo "No accounts found"
    
    echo ""
    echo -e "${YELLOW}Enter email address:${NC}"
    prompt
    read -r email
    
    if [[ -z "$email" ]]; then
        echo -e "${RED}❌ Email address cannot be empty${NC}"
        wait_enter
        return
    fi
    
    # ドメイン自動補完
    if [[ "$email" != *"@"* ]]; then
        email="${email}@${DOMAIN}"
    fi
    
    # パスワード選択
    echo ""
    echo -e "${YELLOW}New password option:${NC}"
    echo "  1) Auto-generate secure password"
    echo "  2) Enter custom password"
    echo ""
    prompt
    read -r pass_option
    
    local password=""
    case "$pass_option" in
        "1")
            echo -e "${GREEN}Auto-generating password...${NC}"
            ;;
        "2")
            echo -e "${YELLOW}Enter new password:${NC}"
            prompt
            read -r password
            ;;
        *)
            echo -e "${RED}Invalid option. Auto-generating password...${NC}"
            ;;
    esac
    
    # パスワード変更実行
    echo ""
    echo -e "${BLUE}Changing password for: $email${NC}"
    
    if [[ -n "$password" ]]; then
        $EMAIL_MANAGER password "$email" "$password"
    else
        $EMAIL_MANAGER password "$email"
    fi
    
    wait_enter
}

# アカウント検索
search_accounts() {
    clear_screen
    echo -e "${CYAN}🔍 Search Email Accounts${NC}"
    echo ""
    
    echo -e "${YELLOW}Enter search term (username or partial email):${NC}"
    prompt
    read -r search_term
    
    if [[ -z "$search_term" ]]; then
        echo -e "${RED}❌ Search term cannot be empty${NC}"
        wait_enter
        return
    fi
    
    echo ""
    echo -e "${BLUE}🔍 Searching for: $search_term${NC}"
    echo ""
    
    # アカウント検索
    if $EMAIL_MANAGER list | grep -i "$search_term"; then
        echo ""
        echo -e "${GREEN}✅ Search completed${NC}"
    else
        echo -e "${YELLOW}No accounts found matching: $search_term${NC}"
    fi
    
    # メールボックス検索
    echo ""
    echo -e "${BLUE}📁 Checking mailbox directories...${NC}"
    if docker exec mailserver ls -la "/var/mail/$DOMAIN/" 2>/dev/null | grep -i "$search_term"; then
        echo -e "${GREEN}✅ Mailbox search completed${NC}"
    else
        echo -e "${YELLOW}No mailbox directories found matching: $search_term${NC}"
    fi
    
    wait_enter
}

# 統計情報
show_statistics() {
    clear_screen
    echo -e "${CYAN}📊 Account Statistics${NC}"
    echo ""
    
    # アカウント数
    local account_count=$($EMAIL_MANAGER list 2>/dev/null | grep -c "^\*" || echo "0")
    echo -e "${BLUE}📧 Total Accounts: ${GREEN}$account_count${NC}"
    
    # メールボックス数
    local mailbox_count=$(docker exec mailserver ls -la "/var/mail/$DOMAIN/" 2>/dev/null | grep -c "^d" || echo "0")
    echo -e "${BLUE}📁 Mailbox Directories: ${GREEN}$mailbox_count${NC}"
    
    # ディスク使用量
    local disk_usage=$(docker exec mailserver du -sh "/var/mail/$DOMAIN/" 2>/dev/null | cut -f1 || echo "N/A")
    echo -e "${BLUE}💾 Disk Usage: ${GREEN}$disk_usage${NC}"
    
    # 最近作成されたアカウント
    echo ""
    echo -e "${BLUE}📅 Recently Created Mailboxes:${NC}"
    docker exec mailserver ls -lat "/var/mail/$DOMAIN/" 2>/dev/null | head -5 || echo "No data available"
    
    wait_enter
}

# 一括操作
bulk_operations() {
    clear_screen
    echo -e "${CYAN}🚀 Bulk Operations${NC}"
    echo ""
    
    echo "  1) 🧹 Clean up empty mailboxes"
    echo "  2) 🔄 Recreate all INBOXes"
    echo "  3) 📋 Export account list"
    echo "  4) 🏠 Back to main menu"
    echo ""
    prompt
    read -r bulk_option
    
    case "$bulk_option" in
        "1")
            echo -e "${BLUE}🧹 Cleaning up empty mailboxes...${NC}"
            docker exec mailserver find "/var/mail/$DOMAIN/" -type d -empty -exec rmdir {} + 2>/dev/null || echo "No empty directories found"
            echo -e "${GREEN}✅ Cleanup completed${NC}"
            wait_enter
            ;;
        "2")
            echo -e "${BLUE}🔄 Recreating INBOXes for all accounts...${NC}"
            $EMAIL_MANAGER list | grep "^\*" | while read -r line; do
                email=$(echo "$line" | awk '{print $2}' | tr -d '()')
                if [[ -n "$email" ]]; then
                    echo "Creating INBOX for: $email"
                    docker exec mailserver doveadm mailbox create -u "$email" INBOX 2>/dev/null || echo "  - Failed or already exists"
                fi
            done
            echo -e "${GREEN}✅ INBOX recreation completed${NC}"
            wait_enter
            ;;
        "3")
            local export_file="/tmp/denzirou_accounts_$(date +%Y%m%d_%H%M%S).txt"
            echo -e "${BLUE}📋 Exporting account list to: $export_file${NC}"
            $EMAIL_MANAGER list > "$export_file"
            echo -e "${GREEN}✅ Export completed: $export_file${NC}"
            wait_enter
            ;;
        "4")
            return
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            wait_enter
            ;;
    esac
}

# メインループ
main_loop() {
    while true; do
        clear_screen
        show_main_menu
        prompt
        read -r choice
        
        case "$choice" in
            "1") list_accounts_interactive ;;
            "2") create_account_interactive ;;
            "3") delete_account_interactive ;;
            "4") change_password_interactive ;;
            "5") 
                echo -e "${BLUE}🧪 Creating test account...${NC}"
                $EMAIL_MANAGER quick test
                wait_enter
                ;;
            "6") 
                echo -e "${BLUE}⏰ Creating temporary account...${NC}"
                $EMAIL_MANAGER quick temp
                wait_enter
                ;;
            "7") search_accounts ;;
            "8") show_statistics ;;
            "9") bulk_operations ;;
            "0") 
                clear_screen
                echo -e "${GREEN}👋 Thank you for using Denzirou Email Administration!${NC}"
                echo ""
                exit 0
                ;;
            *) 
                echo -e "${RED}❌ Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Docker Mailserver確認
if ! docker ps | grep -q "mailserver"; then
    clear_screen
    echo -e "${RED}❌ Error: Mailserver is not running${NC}"
    echo ""
    echo "Please start the mailserver first:"
    echo "  docker compose -f docker-compose.mailserver.yml up -d"
    echo ""
    exit 1
fi

# メインループ開始
main_loop