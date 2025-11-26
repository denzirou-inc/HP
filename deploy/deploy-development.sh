#!/bin/bash
# 開発環境専用デプロイスクリプト
# Usage: ./deploy-development.sh [--force]

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# デフォルト設定
ENVIRONMENT="development"
FORCE_DEPLOY=false

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_DEPLOY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --force      強制デプロイ（確認スキップ）"
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
ENV_FILE="$SCRIPT_DIR/config/development.env"
if [[ ! -f "$ENV_FILE" ]]; then
    # 開発環境用設定がない場合は本番設定をベースに作成
    cp "$SCRIPT_DIR/config/production.env" "$ENV_FILE"
fi
source "$ENV_FILE"

# ログ設定
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/deploy-development-${TIMESTAMP}.log"
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
    log_info "🚀 開発環境デプロイを開始します"

    # 確認
    if [[ "$FORCE_DEPLOY" == "false" ]]; then
        echo "開発環境にデプロイします。"
        read -p "続行しますか？ (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "デプロイを中止しました"
            exit 0
        fi
    fi

    # ファイル転送
    log_info "開発環境用ファイルを転送中..."
    rsync -avz --delete \
        -e "ssh -i ~/.ssh/id_rsa_denzirou" \
        --exclude-from="$SCRIPT_DIR/config/rsync-exclude.txt" \
        "${PROJECT_ROOT}/" \
        "admin@denzirou.com:/opt/denzirou-multi-env/development/"

    # 開発環境デプロイ実行
    ssh "admin:denzirou_web" << 'EOF'
        cd /opt/denzirou-multi-env/development

        # 既存コンテナ停止
        docker compose -f docker/docker-compose.development.yml -p denzirou-development down || true

        # 開発環境用設定
        cat > .env.development << 'DEVENV'
NODE_ENV=development
SMTP_HOST=
SMTP_PORT=
SMTP_USER=
SMTP_PASS=
MAIL_TO=dev@denzirou.com
DEVENV

        # 新しいコンテナ起動
        docker compose -f docker/docker-compose.development.yml -p denzirou-development up -d --build

        # コンテナ起動待機とヘルスチェック
        echo "コンテナ起動待機中..."
        sleep 10

        # Docker コンテナ状態確認
        if ! docker ps | grep -q "denzirou-dev-web"; then
            echo "❌ Webコンテナが起動していません"
            docker ps | grep denzirou-dev
            exit 1
        fi
        echo "✅ Docker コンテナ起動確認"

        # Nginxプロキシ経由でのヘルスチェック（最終確認）
        echo "Nginxプロキシ経由ヘルスチェック中..."
        for i in {1..18}; do
            if curl -f -s http://localhost:8081/health >/dev/null 2>&1; then
                echo "✅ 開発環境起動完了 - nginxプロキシ応答確認"
                exit 0
            fi
            if [ $i -eq 18 ]; then
                echo "❌ Nginxプロキシヘルスチェックがタイムアウトしました"
                docker logs denzirou-dev-web | tail -3
                exit 1
            fi
            echo "Nginxプロキシ待機中... ($i/18) - 5秒後に再試行"
            sleep 5
        done
EOF

    log_info "🎉 開発環境デプロイが完了しました！"
    log_info "URL: http://dev.denzirou.jp (メインプロキシ設定後)"
    log_info "直接アクセス: http://os3-379-22933.vs.sakura.ne.jp:8081"
    log_info "認証情報: dev / [設定したパスワード]"
}

# 実行
main