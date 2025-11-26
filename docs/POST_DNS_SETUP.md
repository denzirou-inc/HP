# DNS変更完了後の設定手順

## 🎯 DNS変更完了確認

DNS変更完了後、以下のコマンドで確認してください：

```bash
# DNS変更の確認
dig +short A denzirou.jp
dig +short A www.denzirou.jp
dig +short A dev.denzirou.jp

# 期待する結果: すべて 133.167.99.187
```

## 🔧 SSL証明書の自動取得

DNS変更が確認できたら、以下を実行してください：

```bash
# SSL証明書取得
sudo certbot --nginx -d denzirou.jp -d www.denzirou.jp \
  -d dev.denzirou.jp --non-interactive --agree-tos \
  -m contact@denzirou.com

# Nginx設定テスト
sudo nginx -t

# Nginx再起動
sudo systemctl reload nginx
```

## ✅ 完成後の動作確認

### 本番環境

```bash
# HTTPSアクセス確認
curl -I https://denzirou.jp
curl -I https://www.denzirou.jp

# HTTPからHTTPSへのリダイレクト確認
curl -I http://denzirou.jp
```

### 開発環境

```bash
# Basic認証確認
curl -I https://dev.denzirou.jp
# → 401 Unauthorized が返ること

# Basic認証付きアクセス
curl -I -u dev:DevPass2025! https://dev.denzirou.jp
# → 200 OK が返ること
```

## 🎉 完成後のアクセスURL

| 環境 | URL | 認証 | 説明 |
|------|-----|------|------|
| 本番 | <https://denzirou.jp> | なし | 公開サイト |
| 本番 | <https://www.denzirou.jp> | なし | 公開サイト |
| 開発 | <https://dev.denzirou.jp> | dev/DevPass2025! | 開発環境 |

## 📝 メモ

- Let's Encryptの証明書は90日ごとに自動更新されます
- 開発環境のパスワードは必要に応じて変更してください
- DNSの変更には最大24時間かかる場合があります

---

**DNS変更完了後、上記手順を実行してください！**
