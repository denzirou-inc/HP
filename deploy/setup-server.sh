#!/bin/bash
# Sakura VPS 初期サーバーセットアップスクリプト
# Usage: ./setup-server.sh [production]

set -e

# デフォルト設定
ENVIRONMENT="${1:-production}"

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 設定ファイル読み込み
ENV_FILE="$SCRIPT_DIR/config/${ENVIRONMENT}.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "❌ 環境設定ファイルが見つかりません: $ENV_FILE"
    exit 1
fi

# shellcheck source=deploy/config/production.env
source "$ENV_FILE"

# ログ設定
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/setup-server-${ENVIRONMENT}-${TIMESTAMP}.log"
mkdir -p "$LOG_DIR"

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

# サーバー初期セットアップ
setup_server() {
    log_info "サーバー初期セットアップを開始します"

    ssh "admin:denzirou_web" << 'EOF'
        # システム更新
        echo "システムを更新中..."
        sudo apt update && sudo apt upgrade -y

        # 必要なパッケージのインストール
        echo "必要なパッケージをインストール中..."
        sudo apt install -y \
            curl \
            wget \
            git \
            vim \
            htop \
            unzip \
            software-properties-common \
            apt-transport-https \
            ca-certificates \
            gnupg \
            lsb-release \
            fail2ban \
            ufw \
            mailutils
        
        # Docker インストール
        if ! command -v docker >/dev/null 2>&1; then
            echo "Dockerをインストール中..."

            # Docker公式GPGキーを追加
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

            # Dockerリポジトリを追加
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Dockerをインストール
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

            # Dockerサービス開始
            sudo systemctl start docker
            sudo systemctl enable docker

            # 現在のユーザーをdockerグループに追加
            sudo usermod -aG docker $USER

            echo "✅ Docker インストール完了"
        else
            echo "✅ Docker は既にインストール済み"
        fi

        # Node.js インストール（管理用）
        if ! command -v node >/dev/null 2>&1; then
            echo "Node.jsをインストール中..."
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt install -y nodejs
            echo "✅ Node.js インストール完了"
        else
            echo "✅ Node.js は既にインストール済み"
        fi

        # 基本的なファイアウォール設定
        echo "基本的なファイアウォール設定中..."
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw --force enable

        # ディレクトリ作成
        echo "プロジェクトディレクトリを作成中..."
        sudo mkdir -p "${DEPLOY_PATH}"
        sudo mkdir -p "${BACKUP_PATH}"
        sudo chown -R admin:admin "${DEPLOY_PATH}"
        sudo chown -R admin:admin "${BACKUP_PATH}"

        # Git設定
        git config --global user.name "Deploy User"
        git config --global user.email "${NOTIFICATION_EMAIL}"

        echo "✅ サーバー初期セットアップ完了"
EOF

    log_info "✅ サーバー初期セットアップ完了"
}

# SSL証明書用Nginx設定
setup_nginx_ssl() {
    log_info "SSL証明書用Nginx設定を作成中..."

    ssh "admin:denzirou_web" << 'EOF'
        # Nginx インストール
        if ! command -v nginx >/dev/null 2>&1; then
            echo "Nginxをインストール中..."
            sudo apt install -y nginx
            sudo systemctl start nginx
            sudo systemctl enable nginx
        fi

        # 基本的なNginx設定
        sudo tee /etc/nginx/sites-available/default > /dev/null << 'NGINXCONF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
NGINXCONF

        # Nginx設定テストと再読み込み
        sudo nginx -t && sudo systemctl reload nginx

        echo "✅ Nginx設定完了"
EOF

    log_info "✅ SSL証明書用Nginx設定完了"
}

# Let's Encrypt証明書取得
setup_ssl_certificates() {
    log_info "SSL証明書を設定中..."

    ssh "admin:denzirou_web" << 'EOF'
        # Certbot インストール
        if ! command -v certbot >/dev/null 2>&1; then
            echo "Certbotをインストール中..."
            sudo apt install -y certbot python3-certbot-nginx
        fi

        # SSL証明書取得（Webサイト用）
        echo "Webサイト用SSL証明書を取得中..."
        sudo certbot --nginx -d ${WEB_DOMAIN} \
            --email ${SSL_EMAIL} \
            --agree-tos \
            --non-interactive \
            --redirect || echo "証明書取得に失敗しました（ドメイン設定を確認してください）"

        # 自動更新設定
        sudo systemctl enable certbot.timer

        echo "✅ SSL証明書設定完了"
EOF

    log_info "✅ SSL証明書設定完了"
}

# システム監視設定
setup_monitoring() {
    log_info "システム監視を設定中..."

    ssh "admin:denzirou_web" << 'EOF'
        # システム監視スクリプト作成
        sudo tee /usr/local/bin/system-monitor.sh > /dev/null << 'MONITOR'
#!/bin/bash
# システム監視スクリプト

# ディスク使用量チェック
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "警告: ディスク使用量が${DISK_USAGE}%に達しました" | \
        mail -s "ディスク容量警告 - $(hostname)" "${NOTIFICATION_EMAIL}" || true
fi

# メモリ使用量チェック
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2 }')
if [ "$MEMORY_USAGE" -gt 90 ]; then
    echo "警告: メモリ使用量が${MEMORY_USAGE}%に達しました" | \
        mail -s "メモリ使用量警告 - $(hostname)" "${NOTIFICATION_EMAIL}" || true
fi

# サービス状態チェック
services=("nginx" "docker" "ssh")
for service in "${services[@]}"; do
    if ! systemctl is-active --quiet "$service"; then
        echo "警告: $service サービスが停止しています" | \
            mail -s "サービス停止警告 - $(hostname)" "${NOTIFICATION_EMAIL}" || true
    fi
done
MONITOR
        
        sudo chmod +x /usr/local/bin/system-monitor.sh
        
        # cron設定
        (crontab -l 2>/dev/null; echo "*/15 * * * * /usr/local/bin/system-monitor.sh") | crontab -
        
        echo "✅ システム監視設定完了"
EOF
    
    log_info "✅ システム監視設定完了"
}

# SSH強化
setup_ssh_security() {
    log_info "SSH設定を強化中..."
    
    ssh "admin:denzirou_web" << 'EOF'
        # SSH設定バックアップ
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
        
        # SSH設定強化
        sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
        sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
        
        # SSH設定テストと再起動
        sudo sshd -t && sudo systemctl reload ssh
        
        echo "✅ SSH設定強化完了"
EOF
    
    log_info "✅ SSH設定強化完了"
}

# デプロイキー設定
setup_deploy_keys() {
    log_info "デプロイキーを設定中..."
    
    # ローカルの公開鍵をサーバーに追加
    if [[ -f "${SSH_KEY_PATH}.pub" ]]; then
        # SSH key already configured in SSH config
        echo "SSH key already configured via SSH config"
        log_info "✅ 公開鍵認証設定完了"
    else
        log_warn "公開鍵ファイルが見つかりません: ${SSH_KEY_PATH}.pub"
    fi
}

# 初期設定完了確認
verify_setup() {
    log_info "サーバー設定を確認中..."
    
    ssh "admin:denzirou_web" << 'EOF'
        echo "=== システム情報 ==="
        uname -a
        echo
        
        echo "=== Dockerバージョン ==="
        docker --version
        docker compose version
        echo
        
        echo "=== ディスク使用量 ==="
        df -h
        echo
        
        echo "=== メモリ情報 ==="
        free -h
        echo
        
        echo "=== サービス状況 ==="
        systemctl status nginx --no-pager -l
        systemctl status docker --no-pager -l
        echo
        
        echo "=== ファイアウォール状況 ==="
        sudo ufw status
        echo
        
        echo "✅ サーバー設定確認完了"
EOF
    
    log_info "✅ サーバー設定確認完了"
}

# メイン実行
main() {
    log_info "🚀 Sakura VPSサーバーセットアップを開始します"
    log_info "環境: $ENVIRONMENT"
    log_info "サーバー: ${SERVER_USER}@${SERVER_HOST}"
    
    # 確認
    echo
    echo "以下の設定でサーバーをセットアップします："
    echo "  環境: $ENVIRONMENT"
    echo "  サーバー: ${SERVER_USER}@${SERVER_HOST}:${SSH_PORT:-22}"
    echo "  デプロイパス: $DEPLOY_PATH"
    echo "  ドメイン: $WEB_DOMAIN"
    echo
    read -p "サーバーセットアップを実行しますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "セットアップを中止しました"
        exit 0
    fi
    
    # セットアップ実行
    setup_server
    setup_ssh_security
    setup_deploy_keys
    setup_nginx_ssl
    setup_ssl_certificates
    setup_monitoring
    verify_setup
    
    log_info "🎉 サーバーセットアップが正常に完了しました！"
    log_info "ログファイル: $LOG_FILE"
    
    echo
    echo "📋 次の手順:"
    echo "1. DNS設定の確認"
    echo "2. SSL証明書の確認: https://${WEB_DOMAIN}"
    echo "3. アプリケーションデプロイ: ./deploy-web.sh $ENVIRONMENT"
    echo "4. メールサーバーデプロイ: ./deploy-mail.sh $ENVIRONMENT"
    echo
    echo "🔗 有用なコマンド:"
    echo "  サーバー接続: ssh admin:denzirou_web"
    echo "  システム監視: ssh admin:denzirou_web 'sudo /usr/local/bin/system-monitor.sh'"
    echo "  Docker状態: ssh admin:denzirou_web 'docker ps'"
}

# 実行
main