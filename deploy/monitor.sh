#!/bin/bash
# デプロイメント監視スクリプト
# Usage: ./monitor.sh [production|staging] [--watch] [--alerts]

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# デフォルト設定
ENVIRONMENT="${1:-production}"
WATCH_MODE=false
ENABLE_ALERTS=false

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --watch)
            WATCH_MODE=true
            shift
            ;;
        --alerts)
            ENABLE_ALERTS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [production|staging] [--watch] [--alerts]"
            echo "Options:"
            echo "  --watch    連続監視モード（5秒間隔）"
            echo "  --alerts   アラート通知を有効化"
            exit 0
            ;;
        production|staging)
            ENVIRONMENT=$1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# 設定読み込み
ENV_FILE="$SCRIPT_DIR/config/${ENVIRONMENT}.env"
if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ 環境設定ファイルが見つかりません: $ENV_FILE"
    exit 1
fi

source "$ENV_FILE"

# ログ設定
LOG_FILE="$SCRIPT_DIR/logs/monitor-${ENVIRONMENT}.log"
mkdir -p "$(dirname "$LOG_FILE")"

# ログ関数
log() {
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# アラート送信
send_alert() {
    local level="$1"
    local message="$2"
    
    if [[ "$ENABLE_ALERTS" == "true" ]]; then
        if command -v mail >/dev/null 2>&1 && [[ -n "$NOTIFICATION_EMAIL" ]]; then
            echo -e "$message" | mail -s "[$PROJECT_NAME] Monitor Alert [$level]" "$NOTIFICATION_EMAIL" || true
        fi
    fi
}

# システム情報取得
get_system_info() {
    ssh "admin:denzirou_web" << 'EOF'
        echo "=== システム情報 ==="
        echo "ホスト名: $(hostname)"
        echo "アップタイム: $(uptime)"
        echo "現在時刻: $(date)"
        echo
        
        echo "=== CPU・メモリ使用量 ==="
        echo "CPU使用率:"
        top -bn1 | grep "Cpu(s)" || echo "N/A"
        echo
        echo "メモリ使用量:"
        free -h
        echo
        
        echo "=== ディスク使用量 ==="
        df -h | grep -E '^/dev/'
        echo
        
        echo "=== ネットワーク ==="
        ss -tuln | grep -E ':(80|443|25|465|587|993|3000)' || echo "主要ポートの状態を確認できませんでした"
        echo
EOF
}

# Docker監視
monitor_docker() {
    log "=== Docker監視 ==="
    
    ssh "admin:denzirou_web" << EOF
        echo "Docker サービス状況:"
        if systemctl is-active --quiet docker; then
            echo "✅ Docker サービス: 正常稼働"
        else
            echo "❌ Docker サービス: 停止"
            exit 1
        fi
        echo
        
        echo "実行中のコンテナ:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo
        
        echo "Dockerリソース使用量:"
        docker system df
        echo
EOF
    
    if [[ $? -ne 0 ]] && [[ "$ENABLE_ALERTS" == "true" ]]; then
        send_alert "CRITICAL" "Docker サービスが停止しています\\nサーバー: ${SERVER_HOST}\\n時刻: $(date)"
    fi
}

# Webアプリケーション監視
monitor_web_app() {
    log "=== Webアプリケーション監視 ==="
    
    local web_url="${HEALTHCHECK_URL:-https://${WEB_DOMAIN}}"
    
    # HTTP レスポンス確認
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$web_url" || echo "000")
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time 10 "$web_url" || echo "0")
    
    echo "Webアプリケーション状況:"
    echo "URL: $web_url"
    echo "HTTPレスポンスコード: $response_code"
    echo "レスポンス時間: ${response_time}s"
    
    if [[ "$response_code" == "200" ]]; then
        echo "✅ Webアプリケーション: 正常稼働"
    else
        echo "❌ Webアプリケーション: 異常 (Code: $response_code)"
        if [[ "$ENABLE_ALERTS" == "true" ]]; then
            send_alert "WARNING" "Webアプリケーションが異常です\\nURL: $web_url\\nレスポンスコード: $response_code\\n時刻: $(date)"
        fi
    fi
    
    # レスポンス時間チェック
    if (( $(echo "$response_time > 5.0" | bc -l) )); then
        echo "⚠️  レスポンス時間が遅い: ${response_time}s"
        if [[ "$ENABLE_ALERTS" == "true" ]]; then
            send_alert "WARNING" "Webアプリケーションのレスポンス時間が遅いです\\nURL: $web_url\\nレスポンス時間: ${response_time}s\\n時刻: $(date)"
        fi
    fi
    
    echo
    
    # Docker Composeサービス状況
    ssh "admin:denzirou_web" << EOF
        cd "${DEPLOY_PATH}" || exit 1
        echo "Docker Composeサービス状況:"
        docker compose -p "${PROJECT_NAME}" ps
        echo
EOF
}

# メールサーバー監視
monitor_mail_server() {
    log "=== メールサーバー監視 ==="
    
    local mail_host="${MAIL_HOST:-mail.${MAIL_DOMAIN}}"
    
    echo "メールサーバー状況:"
    echo "ホスト: $mail_host"
    
    # SMTP ポート確認
    local ports=(25 465 587 993)
    local port_status=true
    
    for port in "${ports[@]}"; do
        if timeout 5 bash -c "echo quit | telnet $mail_host $port" >/dev/null 2>&1; then
            echo "✅ ポート $port: 接続可能"
        else
            echo "❌ ポート $port: 接続不可"
            port_status=false
        fi
    done
    
    if [[ "$port_status" == "false" ]] && [[ "$ENABLE_ALERTS" == "true" ]]; then
        send_alert "CRITICAL" "メールサーバーのポート接続に問題があります\\nホスト: $mail_host\\n時刻: $(date)"
    fi
    
    echo
    
    # メールサーバーコンテナ状況
    ssh "admin:denzirou_web" << EOF
        cd "${DEPLOY_PATH}/docker/mailserver" || exit 1
        echo "メールサーバーコンテナ状況:"
        docker compose -f docker-compose.mailserver.yml ps || echo "メールサーバーが設定されていません"
        echo
EOF
}

# SSL証明書監視
monitor_ssl_certificates() {
    log "=== SSL証明書監視 ==="
    
    local domains=("$WEB_DOMAIN")
    [[ -n "$MAIL_HOST" ]] && domains+=("$MAIL_HOST")
    
    for domain in "${domains[@]}"; do
        echo "SSL証明書確認: $domain"
        
        # 証明書有効期限確認
        local cert_info
        cert_info=$(echo | openssl s_client -connect "${domain}:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || echo "")
        
        if [[ -n "$cert_info" ]]; then
            local not_after
            not_after=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
            
            if [[ -n "$not_after" ]]; then
                local expiry_epoch
                expiry_epoch=$(date -d "$not_after" +%s)
                local current_epoch
                current_epoch=$(date +%s)
                local days_until_expiry
                days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
                
                echo "有効期限まで: ${days_until_expiry}日"
                
                if [[ $days_until_expiry -lt 30 ]]; then
                    echo "⚠️  証明書の有効期限が近づいています"
                    if [[ "$ENABLE_ALERTS" == "true" ]]; then
                        send_alert "WARNING" "SSL証明書の有効期限が近づいています\\nドメイン: $domain\\n残り日数: ${days_until_expiry}日\\n時刻: $(date)"
                    fi
                else
                    echo "✅ 証明書: 正常"
                fi
            else
                echo "❌ 証明書情報を取得できませんでした"
            fi
        else
            echo "❌ SSL接続できませんでした"
        fi
        echo
    done
}

# ログ監視
monitor_logs() {
    log "=== ログ監視 ==="
    
    ssh "admin:denzirou_web" << 'EOF'
        echo "システムログ（エラーレベル）:"
        journalctl --since "1 hour ago" --priority=err --no-pager -q | tail -10 || echo "エラーログはありません"
        echo
        
        echo "Nginxエラーログ:"
        if [[ -f /var/log/nginx/error.log ]]; then
            tail -10 /var/log/nginx/error.log || echo "Nginxエラーログを読み取れません"
        else
            echo "Nginxログファイルが見つかりません"
        fi
        echo
        
        echo "Docker ログ（エラー）:"
        docker logs --since 1h $(docker ps -q) 2>&1 | grep -i error | tail -10 || echo "Dockerエラーログはありません"
        echo
EOF
}

# 監視実行
run_monitoring() {
    clear
    echo "🔍 Denzirou Company Web システム監視"
    echo "環境: $ENVIRONMENT"
    echo "サーバー: ${SERVER_USER}@${SERVER_HOST}"
    echo "時刻: $(date)"
    echo "======================================="
    echo
    
    # システム情報
    get_system_info
    
    # 各コンポーネント監視
    monitor_docker
    monitor_web_app
    monitor_mail_server
    monitor_ssl_certificates
    monitor_logs
    
    echo "======================================="
    echo "監視完了: $(date)"
    
    if [[ "$WATCH_MODE" == "false" ]]; then
        echo "ログファイル: $LOG_FILE"
    fi
}

# 監視ダッシュボード
show_dashboard() {
    while true; do
        run_monitoring
        
        if [[ "$WATCH_MODE" == "true" ]]; then
            echo
            echo "⏰ 5秒後に更新されます... (Ctrl+C で終了)"
            sleep 5
        else
            break
        fi
    done
}

# メイン実行
main() {
    log "システム監視開始: $ENVIRONMENT"
    
    # SSH接続確認
    if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
         "${SSH_KEY_PATH:+-i $SSH_KEY_PATH}" \
         "${SERVER_USER}@${SERVER_HOST}" \
         -p "${SSH_PORT:-22}" \
         "echo 'SSH OK'" >/dev/null 2>&1; then
        echo "❌ SSH接続に失敗しました: ${SERVER_USER}@${SERVER_HOST}:${SSH_PORT:-22}"
        exit 1
    fi
    
    # bc コマンド確認
    if ! command -v bc >/dev/null 2>&1; then
        echo "⚠️  bc コマンドがインストールされていません（レスポンス時間計算で必要）"
        echo "インストール: sudo apt install bc"
    fi
    
    # 監視実行
    if [[ "$WATCH_MODE" == "true" ]]; then
        echo "🔄 連続監視モードで開始します..."
        trap 'echo; echo "監視を終了しました"; exit 0' INT
    fi
    
    show_dashboard
}

# 実行
main