#!/bin/bash

# Docker Mailserver アカウント変更監視スクリプト
# postfix-accounts.cfの変更を監視し、新規アカウントのメールボックスを自動作成

set -e

echo "👁️  [WATCH] Account changes monitoring hook starting..."

# inotify-toolsがインストールされているかチェック
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "⚠️  [WATCH] inotify-tools not available, skipping change monitoring"
    exit 0
fi

# バックグラウンドでファイル変更を監視
(
    echo "🔍 [WATCH] Starting file change monitoring for postfix-accounts.cf..."
    
    while inotifywait -e modify,create,move /tmp/docker-mailserver/postfix-accounts.cf 2>/dev/null; do
        echo "🔄 [WATCH] Detected changes in accounts file, processing..."
        sleep 2  # 書き込み完了を待つ
        
        # 新しいアカウントをチェックして必要なメールボックスを作成
        while IFS='|' read -r email encrypted_password; do
            # コメント行や空行をスキップ
            if [[ "$email" =~ ^#.*$ ]] || [[ -z "$email" ]]; then
                continue
            fi
            
            if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
                domain=$(echo "$email" | cut -d'@' -f2)
                user=$(echo "$email" | cut -d'@' -f1)
                
                # メールディレクトリが存在しない場合のみ作成
                if [[ ! -d "/var/mail/$domain/$user" ]]; then
                    echo "📁 [WATCH] Creating new mailbox for: $email"
                    mkdir -p "/var/mail/$domain/$user"
                    chown -R 5000:5000 "/var/mail/$domain"
                    chmod -R 755 "/var/mail/$domain"
                    
                    # Dovecotにメールボックス作成を指示
                    if command -v doveadm >/dev/null 2>&1; then
                        doveadm mailbox create -u "$email" INBOX 2>/dev/null || true
                        doveadm mailbox create -u "$email" Sent 2>/dev/null || true
                        doveadm mailbox create -u "$email" Drafts 2>/dev/null || true
                        doveadm mailbox create -u "$email" Trash 2>/dev/null || true
                    fi
                    
                    echo "✅ [WATCH] New mailbox created for: $email"
                    echo "$(date): Auto-created mailbox for new account: $email" >> /var/log/mail/account-changes.log
                fi
            fi
        done < /tmp/docker-mailserver/postfix-accounts.cf
        
        echo "🔄 [WATCH] Account changes processing completed"
    done
) &

echo "✅ [WATCH] Account changes monitoring started in background (PID: $!)"