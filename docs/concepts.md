# Nix の基本概念

nix-zen を使う上で知っておくと便利な概念を、シンプルに解説します。

## Nix とは

**パッケージマネージャー + ビルドシステム**

```
apt / brew / yum     →  システムにインストール、バージョン競合あり
Nix                  →  /nix/store に隔離、複数バージョン共存可能
```

### 特徴

| 特徴 | 説明 |
|------|------|
| 再現性 | 同じ設定なら誰でも同じ環境 |
| 隔離 | `/nix/store` に閉じ込め、ホストを汚さない |
| ロールバック | 前の状態にいつでも戻せる |
| 宣言的 | 「この状態にしたい」を記述 |

## 主要コンポーネント

### 1. Nix Store (`/nix/store`)

全てのパッケージが格納される場所。

```
/nix/store/
├── abc123-neovim-0.9.0/
├── def456-neovim-0.10.0/   ← 複数バージョン共存可能
├── ghi789-tmux-3.3/
└── ...
```

- パッケージ名にハッシュが付く
- 同じパッケージの異なるバージョンが共存可能
- 削除は `nix-collect-garbage` で一括

### 2. Flakes (`flake.nix`)

**プロジェクトの設定ファイル** (package.json 的なもの)

```nix
# flake.nix (簡略化)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    # ここで環境を定義
  };
}
```

| 要素 | 役割 |
|------|------|
| `inputs` | 依存関係（どこからパッケージを取得するか） |
| `outputs` | 何を出力するか（環境、パッケージなど） |

### 3. Flake Lock (`flake.lock`)

**依存関係のバージョンを固定** (package-lock.json 的なもの)

```bash
# 更新する場合
nix flake update

# 特定の input だけ更新
nix flake lock --update-input nixpkgs
```

### 4. Home Manager

**ユーザー環境を管理するツール**

```nix
# home.nix の例
{
  home.packages = [ pkgs.neovim pkgs.tmux ];

  programs.git = {
    enable = true;
    userName = "Your Name";
  };
}
```

- dotfiles を Nix で管理
- ユーザー単位の設定（sudo 不要で多くの操作が可能）
- 世代管理でロールバック可能

## よく使うコマンド

### Home Manager

```bash
# 設定を適用
home-manager switch --flake .#full-linux

# 世代一覧
home-manager generations

# ロールバック
home-manager rollback

# 特定の世代に戻る
home-manager activate <generation-path>

# 無効化
home-manager uninstall
```

### Nix 全般

```bash
# 一時的な環境に入る
nix shell nixpkgs#python3

# 開発環境に入る (flake.nix がある場合)
nix develop

# ゴミ収集（古いパッケージを削除）
nix-collect-garbage -d

# 使用容量確認
du -sh /nix/store
```

## nix-zen の構造

```
nix-zen/
├── flake.nix          # エントリーポイント
│                       inputs/outputs を定義
│
├── modules/           # 機能ごとに分割
│   ├── core.nix      # 基本パッケージ (neovim, tmux など)
│   ├── dev.nix       # 開発ツール (git, gh など)
│   └── mobile.nix    # モバイル向けエイリアス
│
├── profiles/          # モジュールの組み合わせ
│   ├── full.nix      # core + dev + mobile
│   └── minimal.nix   # core + mobile
│
└── configs/           # 設定ファイル (シンボリックリンクされる)
    ├── nvim/
    ├── tmux/
    └── starship.toml
```

### データフロー

```
flake.nix
    ↓ 選択
profiles/full.nix
    ↓ インポート
modules/core.nix + dev.nix + mobile.nix
    ↓ 参照
configs/nvim/, tmux/, starship.toml
    ↓ home-manager switch
~/.config/nvim, ~/.tmux.conf, ~/.config/starship.toml
```

## メンタルモデル

### 従来のパッケージ管理

```
apt install neovim
  → /usr/bin/neovim (システム共有)
  → バージョン競合の可能性
  → アンインストールが不完全なことも
```

### Nix

```
nix-env -iA nixpkgs.neovim
  → /nix/store/xxx-neovim-0.9.0/bin/neovim
  → シンボリックリンクで PATH に追加
  → 他のバージョンと共存可能
  → 削除は /nix/store から消すだけ
```

### Home Manager

```
home-manager switch
  → 宣言した状態を実現
  → ~/.config/* へシンボリックリンク作成
  → 世代として保存（ロールバック可能）
```

## 次のステップ

- [トラブルシューティング](troubleshooting.md) - 問題が起きたら
- [アンインストール](uninstall.md) - 元に戻したい場合
