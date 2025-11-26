# 多環境システム設計書

## 🏗️ アーキテクチャ概要

### システム構成図

```text
Internet
    ↓
[System Nginx :80] (メインプロキシ)
    ↓
    ├── denzirou.jp → [Production Environment :8080]
    │   └── Docker Network: denzirou-production-network
    │       ├── nginx (内部ルーティング)
    │       └── Next.js App
    │
    └── dev.denzirou.jp → [Development Environment :8081]
        └── Docker Network: denzirou-development-network
            ├── nginx (Basic認証 + 内部ルーティング)
            └── Next.js App
```

## 🔧 技術スタック

### インフラ

- **サーバー**: Sakura VPS (Ubuntu 22.04)
- **コンテナ**: Docker + Docker Compose
- **リバースプロキシ**: System Nginx + Container Nginx
- **SSL**: Let's Encrypt (Certbot)
- **DNS**: denzirou.jp (本番), dev.denzirou.jp (開発)

### アプリケーション

- **フレームワーク**: Next.js 14.2.31 (Full-stack)
- **ランタイム**: Node.js 22-alpine
- **メール**: Nodemailer (SMTP)

## 🌐 環境分離設計

### 本番環境 (Production)

- **ドメイン**: denzirou.jp, <www.denzirou.jp>
- **ポート**: :8080 (内部) → :80 (外部)
- **ネットワーク**: denzirou-production-network
- **認証**: なし (公開)
- **SSL**: Let's Encrypt証明書
- **コンテナプリフィックス**: denzirou-prod-*

### 開発環境 (Development)  

- **ドメイン**: dev.denzirou.jp
- **ポート**: :8081 (内部) → :80 (外部)
- **ネットワーク**: denzirou-development-network  
- **認証**: Basic認証 (dev/DevPass2025!)
- **SSL**: Let's Encrypt証明書
- **コンテナプリフィックス**: denzirou-dev-*

## 🔒 セキュリティ設計

### ネットワーク分離

- 各環境は独立したDockerネットワークで完全分離
- コンテナ間通信は同一ネットワーク内のみ可能
- 外部アクセスはメインプロキシ経由のみ

### アクセス制御

- **本番環境**: 認証なし（公開サイト）
- **開発環境**: Basic認証必須
- **直接ポートアクセス**: 開発時のみ許可

### SSL/TLS

- 全ドメインでHTTPS必須
- HTTP→HTTPSリダイレクト自動設定
- Let's Encryptによる自動証明書更新

## 📂 ディレクトリ構成

```text
/opt/denzirou-multi-env/
├── production/          # 本番環境
│   ├── docker/
│   │   ├── docker-compose.production.yml
│   │   └── nginx/nextjs.conf
│   └── .env.production
├── development/         # 開発環境  
│   ├── docker/
│   │   ├── docker-compose.development.yml
│   │   └── nginx/nextjs.dev.conf
│   └── .env.development
└── shared/             # 共通リソース
    └── ssl/            # SSL証明書
```

## 🚀 デプロイフロー

### 本番環境デプロイ

```bash
./deploy/deploy-production.sh [--force] [--no-backup]
```

### 開発環境デプロイ  

```bash
./deploy/deploy-development.sh [--force]
```

### 自動化機能

- rsyncによる高速ファイル転送
- Docker Compose自動ビルド・起動
- ヘルスチェック実行
- ロールバック機能（本番環境）
- ログ記録・モニタリング

## 📊 モニタリング

### ヘルスチェック

- **本番**: `http://denzirou.jp/proxy-health`
- **開発**: `http://dev.denzirou.jp/dev-info` (要認証)
- **直接アクセス**: `:8080/health`, `:8081/health`

### ログ管理

- デプロイログ: `deploy/logs/`
- システムログ: journalctl
- コンテナログ: docker logs

## 🔧 運用設計

### DNS管理

- denzirou.jp → 133.167.99.187
- <www.denzirou.jp> → 133.167.99.187  
- dev.denzirou.jp → 133.167.99.187

### SSL証明書管理

- 自動取得: Certbot
- 自動更新: systemd timer
- ワイルドカード非対応（個別ドメイン管理）

### バックアップ戦略

- アプリケーションコード: Git管理
- 設定ファイル: 自動バックアップ
- SSL証明書: Let's Encrypt自動管理

## 🎯 拡張性設計

### 新環境追加手順

1. 新しいポート割り当て（例: :8082）
2. Docker Compose設定作成
3. メインプロキシ設定追加
4. DNS設定追加
5. デプロイスクリプト作成

### スケーリング対応

- コンテナ横展開対応
- ロードバランサー追加可能
- データベース外部化対応

---

## まとめ

このアーキテクチャにより、安全で拡張可能な多環境システムを実現
