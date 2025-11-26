#!/bin/bash
# 本番環境専用デプロイスクリプト
# Usage: ./deploy-production.sh [--force] [--no-backup]

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# デフォルト設定
ENVIRONMENT="production"  # 環境設定（production.envファイル名決定用）
FORCE_DEPLOY=false
SKIP_BACKUP=false  # 将来の拡張用

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_DEPLOY=true
            shift
            ;;
        --no-backup)
            SKIP_BACKUP=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --force      強制デプロイ（確認スキップ）"
            echo "  --no-backup  バックアップをスキップ"
            echo "  -h, --help   このヘルプを表示"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# 設定ファイル読み込み
ENV_FILE="$SCRIPT_DIR/config/production.env"
# shellcheck source=deploy/config/production.env
source "$ENV_FILE"

# ログ設定
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/deploy-production-${TIMESTAMP}.log"
mkdir -p "$LOG_DIR"

# ログ関数
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "$LOG_FILE"
}

# メイン処理
main() {
    log_info "🚀 本番環境デプロイを開始します"

    # 確認
    if [[ "$FORCE_DEPLOY" == "false" ]]; then
        echo "本番環境にデプロイしようとしています。"
        echo "この操作によりWebサイトが一時的に停止する可能性があります。"
        read -p "続行しますか？ (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "デプロイを中止しました"
            exit 0
        fi
    fi

    # ファイル転送
    log_info "本番環境用ファイルを転送中..."
    rsync -avz --delete \
        -e "ssh -i ~/.ssh/id_rsa_denzirou" \
        --exclude-from="$SCRIPT_DIR/config/rsync-exclude.txt" \
        "${PROJECT_ROOT}/" \
        "admin@denzirou.com:/opt/denzirou-multi-env/production/"

    # 本番環境デプロイ実行
    ssh "admin:denzirou_web" << 'EOF'
        cd /opt/denzirou-multi-env/production

        # 既存Webコンテナ停止
        docker compose -f docker/docker-compose.production.yml -p denzirou-production down || true

        # 新しいWebコンテナ起動
        docker compose -f docker/docker-compose.production.yml -p denzirou-production up -d --build

        # メールサーバーが停止している場合は再起動
        if ! docker ps | grep -q mailserver; then
            echo "メールサーバーを起動中..."
            docker compose -f docker/mailserver/docker-compose.mailserver.yml up -d
        else
            echo "メールサーバーは既に稼働中です"
        fi

        # Certbot更新フックスクリプトのデプロイ
        echo "Certbot更新フックスクリプトをデプロイ中..."
        sudo mkdir -p /etc/letsencrypt/renewal-hooks/deploy
        sudo cp scripts/certbot/restart-mailserver.sh /etc/letsencrypt/renewal-hooks/deploy/
        sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/restart-mailserver.sh
        echo "✅ Certbot更新フックスクリプトのデプロイ完了"

        # コンテナ起動待機とヘルスチェック
        echo "コンテナ起動待機中..."
        sleep 10

        # Docker コンテナ状態確認
        if ! docker ps | grep -q "denzirou-prod-web"; then
            echo "❌ Webコンテナが起動していません"
            docker ps | grep denzirou-prod
            exit 1
        fi
        echo "✅ Docker コンテナ起動確認"

        # Nginxプロキシ経由でのヘルスチェック（最終確認）
        echo "Nginxプロキシ経由ヘルスチェック中..."
        for i in {1..18}; do
            if curl -f -s http://localhost:8080/health >/dev/null 2>&1; then
                echo "✅ 本番環境デプロイ完了 - nginxプロキシ応答確認"
                break
            fi
            if [ $i -eq 18 ]; then
                echo "❌ Nginxプロキシヘルスチェックがタイムアウトしました"
                echo "コンテナログを確認中..."
                docker logs denzirou-prod-web | tail -3
                exit 1
            fi
            echo "Nginxプロキシ待機中... ($i/18) - 5秒後に再試行"
            sleep 5
        done

EOF

    log_info "🎉 本番環境デプロイが完了しました！"
    log_info "URL: http://denzirou.jp (メインプロキシ設定後)"
    log_info "アクセス: http://os3-379-22933.vs.sakura.ne.jp:8080"
}

# 実行
main