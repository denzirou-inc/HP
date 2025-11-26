# Company-web Makefile
# ローカル開発中心、本番環境はDocker対応

# Auto-detect Docker platform and mail service based on architecture
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
    export DOCKER_PLATFORM=linux/arm64
    MAIL_PROFILE=arm64
    MAIL_SERVICE=mailcatcher
    MAIL_UI_URL=http://localhost:8025
else ifeq ($(ARCH),aarch64)
    export DOCKER_PLATFORM=linux/arm64
    MAIL_PROFILE=arm64
    MAIL_SERVICE=mailcatcher
    MAIL_UI_URL=http://localhost:8025
else
    export DOCKER_PLATFORM=linux/amd64
    MAIL_PROFILE=intel
    MAIL_SERVICE=mailhog
    MAIL_UI_URL=http://localhost:8025
endif

export NODE_VERSION=$(shell cat web/.node-version | tr -d '\r' | tr -d '\n')

# Docker設定
project_name:=denzirou-company-web
dockerLocalCmd:=docker compose -p ${project_name} -f docker/docker-compose.local.yml --profile ${MAIL_PROFILE}

.DEFAULT_GOAL := help

help:
	@echo "📖 Company-web Development Commands"
	@echo ""
	@echo "🖥️  Platform: $(DOCKER_PLATFORM) (Architecture: $(ARCH))"
	@echo "📧 Mail Service: $(MAIL_SERVICE) (Profile: $(MAIL_PROFILE))"
	@echo "🌐 Mail UI: $(MAIL_UI_URL)"
	@echo ""
	@echo "Usage: make SUB_COMMAND"
	@echo ""
	@echo "Command list:"
	@echo ""
	@printf "\033[36m%-30s\033[0m %-50s %s\n" "[Sub command]" "[Description]"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: help dev install lint format build start up down status logs destroy docker-build docker-up docker-down docker-logs docker-status docker-destroy

# ============================================
# ローカル開発コマンド（推奨）
# ============================================

dev: ## ローカル開発サーバー起動（http://localhost:3000）
	@echo "🚀 Starting local development server..."
	@cd web && npm run dev

install: ## 依存関係インストール（npm install）
	@echo "📦 Installing dependencies..."
	@cd web && npm install

lint: ## ESLintによるコードチェック
	@echo "🔍 Running ESLint..."
	@cd web && npm run lint

format: ## Prettierによるコード整形
	@echo "✨ Running Prettier..."
	@cd web && npm run format

build: ## Next.jsアプリケーションのプロダクションビルド
	@echo "🏗️ Building Next.js application..."
	@cd web && npm run build

start: ## ビルド後のプロダクションサーバー起動
	@echo "▶️ Starting production server locally..."
	@cd web && npm run start

# ============================================
# MailHog（メールテスト用）- M1 Mac対応
# ============================================

up: ## メール送信テスト用サービス起動（SMTP:1025, Web UI:8025）
	@echo "📧 Starting $(MAIL_SERVICE) for email testing..."
	@echo "🖥️  Platform: $(DOCKER_PLATFORM) ($(MAIL_PROFILE) profile)"
	${dockerLocalCmd} up -d
	@echo "✅ $(MAIL_SERVICE) started!"
	@echo "   - SMTP: localhost:1025"
	@echo "   - Web UI: $(MAIL_UI_URL)"

down: ## メール送信テスト用サービス停止
	@echo "📧 Stopping $(MAIL_SERVICE)..."
	${dockerLocalCmd} down

status: ## メール送信テスト用コンテナの状態確認
	${dockerLocalCmd} ps

logs: ## メール送信テスト用サービスのログをリアルタイム表示
	${dockerLocalCmd} logs -f $(MAIL_SERVICE)

destroy: ## このプロジェクトのDocker環境リセット（問題解決時）
	@echo "🔄 Resetting $(MAIL_SERVICE) Docker environment..."
	${dockerLocalCmd} down --rmi all --volumes --remove-orphans
	@echo "✅ Project Docker environment reset complete"

# ============================================
# Email Management（簡単メール管理）
# ============================================

email-list: ## メールアカウント一覧表示
	@echo "📋 Listing email accounts..."
	@./scripts/email_manager.sh list

email-create: ## メールアカウント作成（使用例: make email-create EMAIL=user@denzirou.com [PASS=password]）
	@if [ -z "$(EMAIL)" ]; then \
		echo "❌ Usage: make email-create EMAIL=user@denzirou.com [PASS=password]"; \
		echo "Example: make email-create EMAIL=test@denzirou.com"; \
		echo "Example: make email-create EMAIL=test@denzirou.com PASS=mypassword"; \
		exit 1; \
	fi
	@if [ -n "$(PASS)" ]; then \
		./scripts/email_manager.sh create "$(EMAIL)" "$(PASS)"; \
	else \
		./scripts/email_manager.sh create "$(EMAIL)"; \
	fi

email-delete: ## メールアカウント削除（使用例: make email-delete EMAIL=user@denzirou.com）
	@if [ -z "$(EMAIL)" ]; then \
		echo "❌ Usage: make email-delete EMAIL=user@denzirou.com"; \
		exit 1; \
	fi
	@./scripts/email_manager.sh delete "$(EMAIL)"

email-password: ## メールパスワード変更（使用例: make email-password EMAIL=user@denzirou.com [PASS=newpass]）
	@if [ -z "$(EMAIL)" ]; then \
		echo "❌ Usage: make email-password EMAIL=user@denzirou.com [PASS=newpassword]"; \
		exit 1; \
	fi
	@if [ -n "$(PASS)" ]; then \
		./scripts/email_manager.sh password "$(EMAIL)" "$(PASS)"; \
	else \
		./scripts/email_manager.sh password "$(EMAIL)"; \
	fi

email-quick-test: ## テスト用アカウント作成（test+日付@denzirou.com）
	@echo "🧪 Creating quick test account..."
	@./scripts/email_manager.sh quick test

email-quick-temp: ## 一時用アカウント作成（temp+時刻@denzirou.com）
	@echo "⏰ Creating temporary account..."
	@./scripts/email_manager.sh quick temp

email-help: ## メール管理ヘルプ表示
	@./scripts/email_manager.sh help

email-admin: ## インタラクティブメール管理パネル起動
	@echo "🚀 Starting Email Administration Panel..."
	@./scripts/email_admin.sh

email-stats: ## メールアカウント統計情報表示
	@echo "📊 Email Account Statistics:"
	@echo ""
	@echo "📧 Total Accounts:"
	@./scripts/email_manager.sh list | grep -c "^\*" || echo "0"
	@echo ""
	@echo "📁 Mailbox Directories:"
	@docker exec mailserver ls -la /var/mail/denzirou.com/ 2>/dev/null | grep -c "^d" || echo "0"
	@echo ""
	@echo "💾 Disk Usage:"
	@docker exec mailserver du -sh /var/mail/denzirou.com/ 2>/dev/null | cut -f1 || echo "N/A"
