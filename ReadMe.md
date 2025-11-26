# Denzirou Company Web - 統合Webアプリケーション・メールサーバーシステム

**🚀 Next.js Webサイト + 本格メールサーバー統合システム**

## 概要

株式会社藤原伝次郎商店（Denzirou Inc.）SE部門のコーポレートサイト・メールサーバー統合システムです。

### 主要機能

- **Webサイト**: お問い合わせフォーム・採用応募フォーム
- **メールサーバー**: 本格的なメール配信・受信システム
- **メール管理**: 簡単操作でのアカウント作成・削除・管理
- **自動化**: Docker起動時の自動初期化・メールボックス作成

## 技術スタック

### Webアプリケーション

- **Frontend**: Next.js 14 + TypeScript
- **Styling**: Tailwind CSS + Material-UI
- **Validation**: Zod
- **Email**: Nodemailer integration

### メールサーバー

- **Docker Mailserver**: Postfix + Dovecot + Rspamd
- **セキュリティ**: SSL/TLS, Fail2Ban, スパムフィルター
- **自動化**: 起動時自動初期化・メールボックス作成

## 🚀 クイックスタート

### Web開発環境

```bash
make install        # 依存関係インストール
make up             # メールテスト環境起動
make dev            # 開発サーバー起動 → http://localhost:3000
```

### メール管理（対話形式）

```bash
make email-admin    # 管理パネル起動
```

### メール管理（コマンドライン）

```bash
make email-create EMAIL=user@denzirou.com    # アカウント作成
make email-list                              # アカウント一覧
make email-delete EMAIL=user@denzirou.com    # アカウント削除
```

## 📁 プロジェクト構成

```
company-web/
├── web/                    # Next.js Webアプリケーション
│   ├── src/app/
│   │   ├── api/           # API Routes（メール送信等）
│   │   ├── contact/       # お問い合わせページ
│   │   └── recruit/       # 採用応募ページ
├── docker/
│   └── mailserver/        # メールサーバー設定
├── scripts/               # 管理スクリプト
│   ├── email_manager.sh   # CLI メール管理
│   ├── email_admin.sh     # 対話式管理パネル
│   └── mail_commands.sh   # シンプルコマンド集
├── docs/                  # ドキュメント
│   └── EMAIL_MANAGEMENT_GUIDE.md
└── Makefile              # 統一コマンドインターフェース
```

## 🛠️ 開発コマンド

### Web開発

```bash
make help           # 全コマンド一覧・プラットフォーム情報
make install        # 依存関係インストール
make dev            # 開発サーバー起動
make lint           # ESLint + コードチェック
make format         # Prettier + コード整形
make build          # プロダクションビルド
```

### メール管理

```bash
# 対話型管理
make email-admin             # 📧 管理パネル起動

# アカウント操作
make email-create EMAIL=...  # ➕ アカウント作成
make email-list              # 📋 アカウント一覧
make email-delete EMAIL=...  # ❌ アカウント削除
make email-password EMAIL=... # 🔑 パスワード変更

# クイック作成
make email-quick-test        # 🧪 テストアカウント作成
make email-quick-temp        # ⏰ 一時アカウント作成

# 統計・管理
make email-stats             # 📊 統計情報
make email-help              # 💡 ヘルプ表示
```

### メールテスト環境（MailHog）

```bash
make up             # MailHog起動 → http://localhost:8025
make down           # MailHog停止
make status         # コンテナ状態確認
make logs           # ログ表示
```

## 📧 メール設定

### ローカル開発（MailHog）

開発時はMailHogでメール送信をテスト:

```bash
make up             # MailHog起動
# フォームテスト後 → http://localhost:8025 でメール確認
```

**環境変数（.env.development）:**

```env
SMTP_HOST=localhost
SMTP_PORT=1025
MAIL_TO=test@example.com
```

### 本番環境（独自メールサーバー）

Docker Mailserverによる本格的なメールシステム:

- **ドメイン**: denzirou.com
- **暗号化**: Let's Encrypt SSL/TLS
- **セキュリティ**: Fail2Ban + スパムフィルター
- **自動化**: 起動時メールボックス自動作成

## 📚 詳細ドキュメント

システムの詳細な使用方法については、以下のドキュメントを参照:

- **[メール管理完全ガイド](docs/EMAIL_MANAGEMENT_GUIDE.md)** - メールサーバー・アカウント管理の詳細
- **[デプロイガイド](docs/DEPLOYMENT_GUIDE.md)** - 本番環境構築手順
- **[アーキテクチャ](docs/ARCHITECTURE.md)** - システム全体設計

## 🔧 本番環境での使用

### メールアカウント管理（サーバー上）

```bash
# サーバーにSSH接続後
cd /path/to/company-web

# 対話式管理パネル
./scripts/email_admin.sh

# コマンドライン操作
./scripts/email_manager.sh create user@denzirou.com
./scripts/email_manager.sh list
./scripts/email_manager.sh delete user@denzirou.com

# シンプルコマンド（関数読み込み）
source scripts/mail_commands.sh
mail-create user@denzirou.com
mail-list
mail-delete user@denzirou.com
```

### メールサーバー操作

```bash
# サーバー状態確認
docker compose -f docker/mailserver/docker-compose.mailserver.yml ps

# ログ確認
docker compose -f docker/mailserver/docker-compose.mailserver.yml logs -f

# 再起動
docker compose -f docker/mailserver/docker-compose.mailserver.yml restart
```

## 🚀 デプロイ・本番環境

### Web アプリケーション

```bash
make build          # プロダクションビルド
make start          # 本番サーバー起動
```

### Docker環境

```bash
make docker-build   # コンテナビルド
make docker-up      # Docker起動
make docker-status  # 状態確認
make docker-logs    # ログ確認
```

## 🔍 トラブルシューティング

### Web開発

```bash
make install        # 依存関係再インストール
rm -rf web/.next && make dev  # キャッシュクリア
make lint           # コードチェック
```

### メールサーバー

```bash
# サービス確認
docker exec mailserver ss -lntp | grep -E ':25|:587|:993'

# メールボックス確認
docker exec mailserver ls -la /var/mail/denzirou.com/

# ログ確認
docker exec mailserver tail -f /var/log/mail/mail.log
```

詳細なトラブルシューティングは [メール管理ガイド](docs/EMAIL_MANAGEMENT_GUIDE.md) を参照してください。

## 🛠️ 開発のベストプラクティス

### 推奨ワークフロー

1. **初期セットアップ**:

   ```bash
   make help           # 環境確認
   make install        # 依存関係インストール
   make up             # メールテスト環境起動
   ```

2. **日常開発**:

   ```bash
   make dev            # 開発サーバー起動
   # 開発作業...
   make lint format    # コード品質管理
   ```

3. **本番テスト**:
   ```bash
   make build          # 本番ビルドテスト
   make email-create EMAIL=test@denzirou.com  # メール機能テスト
   ```

### 対応プラットフォーム

- **Intel Mac** ✅
- **M1/M2/M3 Mac** ✅（ARM64対応）
- **Linux x64/ARM64** ✅
- **Windows** ✅（Docker Desktop使用）

システムが自動的にプラットフォームを検出し、最適な設定を選択します。

## 📄 ライセンス

© 2024 Denzirou Inc.
