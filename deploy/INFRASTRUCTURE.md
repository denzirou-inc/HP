# インフラ構成図

## 全体システム構成

```mermaid
graph TB
    %% Internet
    Internet[🌐 Internet]
    
    %% DNS
    CloudFlare[☁️ CloudFlare DNS<br/>denzirou.jp<br/>mail.denzirou.com]
    
    %% Sakura VPS
    subgraph SakuraVPS["🖥️ Sakura VPS (Ubuntu 22.04)"]
        subgraph UFW["🔥 UFW Firewall"]
            Port22[Port 22: SSH]
            Port25[Port 25: SMTP]
            Port80[Port 80: HTTP]
            Port443[Port 443: HTTPS]
            Port465[Port 465: SMTPS]
            Port587[Port 587: SMTP-AUTH]
            Port993[Port 993: IMAPS]
            Port8080[Port 8080: 本番Web]
            Port8081[Port 8081: 開発Web]
        end
        
        subgraph SystemServices["🔧 システムサービス"]
            SSH[SSH Service]
            Nginx[Nginx (System)]
            Certbot[Let's Encrypt<br/>Certbot]
            Fail2Ban[Fail2ban]
            Docker[Docker Engine]
        end
        
        subgraph DockerEnv["🐳 Docker環境"]
            subgraph ProdNetwork["本番環境ネットワーク<br/>(denzirou-production-network)"]
                ProdNginx[📦 nginx:latest<br/>Port: 8080→80]
                ProdWeb[📦 Next.js App<br/>内部Port: 3000<br/>外部非公開]
            end
            
            subgraph DevNetwork["開発環境ネットワーク<br/>(denzirou-development-network)"]
                DevNginx[📦 nginx:latest<br/>Port: 8081→80<br/>Basic認証]
                DevWeb[📦 Next.js App<br/>内部Port: 3000<br/>外部非公開]
            end
            
            subgraph MailNetwork["メールサーバーネットワーク<br/>(mailserver-network)"]
                MailServer[📦 docker-mailserver<br/>Ports: 25,465,587,993<br/>Security: ClamAV無効<br/>Memory: 800M制限]
            end
        end
        
        subgraph Storage["💾 ストレージ"]
            MailData[📁 /opt/denzirou-multi-env/<br/>├── production/<br/>├── development/<br/>└── mailserver/data/]
            SSLCerts[🔒 /etc/letsencrypt/<br/>SSL証明書]
            Logs[📄 /var/log/<br/>システムログ]
        end
    end
    
    %% External Services
    LetsEncrypt[🔒 Let's Encrypt<br/>SSL証明書発行]
    
    %% Connections
    Internet --> CloudFlare
    CloudFlare --> SakuraVPS
    LetsEncrypt --> Certbot
    
    %% Internal connections
    Port8080 --> ProdNginx
    Port8081 --> DevNginx
    ProdNginx --> ProdWeb
    DevNginx --> DevWeb
    Port25 --> MailServer
    Port465 --> MailServer
    Port587 --> MailServer
    Port993 --> MailServer
    
    %% Storage connections
    MailServer --> MailData
    Certbot --> SSLCerts
    Docker --> Logs
```

## ネットワーク構成詳細

### 外部アクセス構成

```mermaid
graph LR
    %% Users
    ProdUser[👤 本番ユーザー]
    DevUser[👤 開発者]
    MailUser[📧 メールユーザー]
    
    %% Access paths
    ProdUser --> |http://denzirou.jp:8080| ProdAccess[🌐 本番環境アクセス]
    DevUser --> |http://dev-server:8081<br/>Basic認証| DevAccess[🔒 開発環境アクセス]
    MailUser --> |SMTP/IMAP| MailAccess[📬 メールアクセス]
    
    ProdAccess --> ProdNginx[📦 Production Nginx<br/>Port 8080]
    DevAccess --> DevNginx[📦 Development Nginx<br/>Port 8081]
    MailAccess --> MailServer[📦 Mailserver<br/>Ports 25,465,587,993]
    
    ProdNginx --> |proxy_pass| ProdNextJS[📦 Production Next.js<br/>内部Port 3000]
    DevNginx --> |proxy_pass| DevNextJS[📦 Development Next.js<br/>内部Port 3000]
```

### セキュリティ層構成

```mermaid
graph TB
    subgraph Security["🛡️ セキュリティ層"]
        subgraph L1["L1: ネットワークレベル"]
            UFWFirewall[🔥 UFW Firewall<br/>最小限ポート開放]
            Fail2BanService[🚫 Fail2ban<br/>侵入防止]
        end
        
        subgraph L2["L2: アプリケーションレベル"]
            SSLEncrypt[🔒 SSL/TLS暗号化<br/>Let's Encrypt]
            BasicAuth[🔐 Basic認証<br/>開発環境]
            NginxProxy[🔄 Nginx Proxy<br/>リバースプロキシ]
        end
        
        subgraph L3["L3: コンテナレベル"]
            DockerIsolation[🐳 Docker分離<br/>ネットワーク分離]
            NonRootUser[👤 非root実行<br/>権限最小化]
            ResourceLimit[⚖️ リソース制限<br/>メモリ・CPU制限]
        end
        
        subgraph L4["L4: アプリケーション内部"]
            InputValidation[✅入力検証]
            APISecurity[🔐 API認証]
            LoggingSecurity[📊 セキュリティログ]
        end
    end
```

## デプロイメントフロー

```mermaid
graph TB
    %% Development Flow
    subgraph DevFlow["🔧 開発フロー"]
        LocalDev[💻 ローカル開発]
        GitCommit[📝 Git Commit/Push]
        
        LocalDev --> GitCommit
    end
    
    %% Deployment Flow
    subgraph DeployFlow["🚀 デプロイフロー"]
        DeployScript[📜 deploy-production.sh<br/>deploy-development.sh]
        FileTransfer[📂 rsync ファイル転送]
        DockerBuild[🐳 Docker Build]
        HealthCheck[🏥 ヘルスチェック]
        
        GitCommit --> DeployScript
        DeployScript --> FileTransfer
        FileTransfer --> DockerBuild
        DockerBuild --> HealthCheck
    end
    
    %% Production Environment
    subgraph ProdEnv["🌐 本番環境"]
        ProdService[🏃 本番サービス起動]
        NginxHealth[✅ Nginx ヘルスチェック<br/>:8080/health]
        ServiceMonitor[📊 サービス監視]
        
        HealthCheck --> ProdService
        ProdService --> NginxHealth
        NginxHealth --> ServiceMonitor
    end
    
    %% Rollback Flow
    subgraph RollbackFlow["🔄 ロールバック"]
        ErrorDetection[❌ エラー検出]
        ServiceRestart[🔄 サービス再起動]
        ManualRecover[🛠️ 手動復旧]
        
        ServiceMonitor -.-> ErrorDetection
        ErrorDetection --> ServiceRestart
        ServiceRestart --> ManualRecover
    end
```

## リソース構成

### サーバースペック

```mermaid
graph TB
    subgraph ServerSpec["🖥️ Sakura VPS スペック"]
        CPU[⚡ CPU<br/>詳細不明]
        Memory[💾 メモリ<br/>1.9GB総容量<br/>使用率: 45%]
        Storage[💽 ストレージ<br/>98.34GB<br/>使用率: 23.8%]
        Network[🌐 ネットワーク<br/>ホスト: denzirou.com<br/>IPv4: 133.167.99.187]
    end
    
    subgraph ResourceAllocation["📊 リソース配分"]
        SystemReserved[🔧 システム用<br/>~500MB]
        MailServerLimit[📧 メールサーバー<br/>最大800MB<br/>最小400MB]
        WebApps[🌐 Webアプリ<br/>残りリソース]
        BufferZone[⚖️ バッファ<br/>緊急時用]
        
        Memory --> SystemReserved
        Memory --> MailServerLimit
        Memory --> WebApps
        Memory --> BufferZone
    end
```

### ディスク構成

```bash
# ディスク使用量構成
/                           98.34GB (23.8%使用)
├── /opt/denzirou-multi-env/
│   ├── production/         # 本番環境ファイル
│   ├── development/        # 開発環境ファイル
│   └── logs/              # デプロイログ
├── /etc/letsencrypt/       # SSL証明書
├── /var/lib/docker/        # Dockerデータ
├── /var/log/              # システムログ
└── /home/admin/           # 管理者ホーム
```

## 監視・運用構成

```mermaid
graph TB
    subgraph Monitoring["📊 監視システム"]
        subgraph HealthChecks["🏥 ヘルスチェック"]
            NginxHealthCheck[✅ Nginx Health<br/>/health エンドポイント]
            ContainerHealth[🐳 Container Health<br/>Docker状態監視]
            SystemHealth[🖥️ System Health<br/>CPU/Memory/Disk]
        end
        
        subgraph Logging["📄 ログ管理"]
            DeployLogs[📜 デプロイログ<br/>deploy/logs/]
            SystemLogs[📋 システムログ<br/>/var/log/]
            AppLogs[📱 アプリログ<br/>docker logs]
            SecurityLogs[🔒 セキュリティログ<br/>fail2ban, auth]
        end
        
        subgraph Alerts["🚨 アラート"]
            MemoryAlert[💾 メモリアラート<br/>>90%で通知]
            DiskAlert[💽 ディスクアラート<br/>>80%で通知]
            ServiceAlert[🔧 サービスアラート<br/>停止時通知]
        end
    end
    
    subgraph Operations["🔧 運用管理"]
        subgraph Maintenance["🛠️ メンテナンス"]
            SystemUpdate[🔄 システム更新<br/>定期パッケージ更新]
            SSLRenewal[🔒 SSL更新<br/>Let's Encrypt自動更新]
            LogRotation[📋 ログローテーション<br/>定期ログ整理]
        end
        
        subgraph Backup["💾 バックアップ"]
            ConfigBackup[⚙️ 設定バックアップ<br/>Docker設定等]
            DataBackup[📁 データバックアップ<br/>メールデータ等]
        end
    end
```

## セキュリティ設定詳細

### ファイアウォール設定
```bash
# UFW ファイアウォール設定
sudo ufw default deny incoming    # デフォルト拒否
sudo ufw default allow outgoing   # デフォルト許可
sudo ufw allow ssh               # SSH (22)
sudo ufw allow 80/tcp            # HTTP
sudo ufw allow 443/tcp           # HTTPS  
sudo ufw allow 25/tcp            # SMTP
sudo ufw allow 465/tcp           # SMTPS
sudo ufw allow 587/tcp           # SMTP-AUTH
sudo ufw allow 993/tcp           # IMAPS
sudo ufw allow 8080/tcp          # 本番Web
sudo ufw allow 8081/tcp          # 開発Web
```

### Docker セキュリティ
```yaml
# セキュリティ強化設定
services:
  web:
    # 外部ポート非公開（nginx経由のみ）
    # ports: なし
    
  nginx:
    # 最小限のポート公開
    ports:
      - "8080:80"  # 本番
      - "8081:80"  # 開発
      
  mailserver:
    # メモリ制限でDoS対策
    deploy:
      resources:
        limits:
          memory: 800M
```

この構成により、セキュアで運用しやすいインフラストラクチャが実現されています。