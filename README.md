# nix-zen

Nix 初心者にも使いやすい、軽量な開発環境管理ツール。

**特徴:**
- 🚀 5分で導入完了
- 🔄 いつでもロールバック可能
- 🧹 ホスト環境を汚さない
- 📱 モバイル (SSH) 向け最適化オプション

## クイックスタート (5分)

### 1. Nix インストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

ターミナルを再起動（または `source /etc/profile`）。

### 2. nix-zen 適用

```bash
# リポジトリ取得
git clone https://github.com/stealth-dev-lab/nix-zen.git
cd nix-zen

# 環境を適用 (Linux)
nix run nixpkgs#home-manager -- switch --flake .#full-linux

# macOS の場合
nix run nixpkgs#home-manager -- switch --flake .#full-mac
```

### 3. 完了

新しいターミナルを開くと環境が適用されています。

## 困ったら

```bash
# 前の状態に戻す
home-manager rollback

# 世代一覧を見る
home-manager generations

# nix-zen を無効化
home-manager uninstall
```

詳細: [docs/uninstall.md](docs/uninstall.md)

## プロファイル

| プロファイル | 用途 | 説明 |
|-------------|------|------|
| `full-linux` | デスクトップ / SSH 開発 | フル機能の開発環境 |
| `full-mac` | macOS 開発 | macOS 向けフル環境 |
| `minimal-linux` | モバイル SSH | 軽量 + ショートカット |
| `minimal-mac` | モバイル SSH (macOS) | 軽量 + ショートカット |

## 含まれるツール

### コア
- neovim (設定済み)
- tmux (設定済み)
- starship (プロンプト)
- eza, bat, fd, ripgrep

### 開発ツール (full のみ)
- git, gh
- direnv
- その他

## ディレクトリ構成

```
nix-zen/
├── flake.nix          # エントリーポイント
├── modules/           # 機能モジュール
│   ├── core.nix      # 基本パッケージ
│   ├── dev.nix       # 開発ツール
│   └── mobile.nix    # モバイル最適化
├── profiles/          # プロファイル
│   ├── full.nix      # フル機能
│   └── minimal.nix   # 軽量版
├── configs/           # 設定ファイル
│   ├── nvim/
│   ├── tmux/
│   └── starship.toml
└── docs/              # ドキュメント
    ├── getting-started.md
    ├── concepts.md
    ├── troubleshooting.md
    └── uninstall.md
```

## モバイル向けショートカット

| エイリアス | コマンド |
|-----------|---------|
| `g` | git |
| `gs` | git status |
| `gc` | git commit |
| `ta` | tmux attach -t |
| `tl` | tmux list-sessions |
| `l` | eza -la |
| `e` | $EDITOR |

## ドキュメント

- [導入ガイド](docs/getting-started.md) - 詳細なインストール手順
- [Nix の基本概念](docs/concepts.md) - flake, home-manager の解説
- [トラブルシューティング](docs/troubleshooting.md) - よくある問題と解決法
- [アンインストール](docs/uninstall.md) - ロールバック・削除方法

## ライセンス

MIT

---

Part of [stealth-dev-lab](https://github.com/stealth-dev-lab).
