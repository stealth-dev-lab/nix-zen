# 導入ガイド

nix-zen の詳細なインストール手順です。

## 前提条件

- Linux (Ubuntu, Fedora, Arch など) または macOS
- curl, git がインストール済み
- sudo 権限

## Step 1: Nix のインストール

### 推奨: Determinate Systems Installer

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

このインストーラーは:
- Flakes をデフォルトで有効化
- アンインストーラーを提供
- macOS でも安定動作

### 代替: 公式インストーラー

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

公式の場合、Flakes を手動で有効化する必要があります:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### インストール確認

```bash
# ターミナルを再起動してから
nix --version
# nix (Nix) 2.x.x
```

## Step 2: nix-zen の取得

```bash
git clone https://github.com/stealth-dev-lab/nix-zen.git
cd nix-zen
```

## Step 3: プロファイルの選択と適用

### Linux の場合

```bash
# フル機能 (推奨)
nix run nixpkgs#home-manager -- switch --flake .#full-linux

# または軽量版 (モバイル SSH 向け)
nix run nixpkgs#home-manager -- switch --flake .#minimal-linux
```

### macOS の場合

```bash
# フル機能
nix run nixpkgs#home-manager -- switch --flake .#full-mac

# 軽量版
nix run nixpkgs#home-manager -- switch --flake .#minimal-mac
```

### 初回実行時の注意

初回は依存パッケージのダウンロードに時間がかかります（5-15分程度）。
2回目以降はキャッシュされるため高速です。

## Step 4: 確認

新しいターミナルを開いて確認:

```bash
# starship プロンプトが表示される
# neovim が使える
nvim --version

# tmux が使える
tmux -V

# エイリアスが効く
gs  # git status
l   # eza -la
```

## 次のステップ

- [Nix の基本概念](concepts.md) - 仕組みを理解する
- [トラブルシューティング](troubleshooting.md) - 問題が起きたら
- [アンインストール](uninstall.md) - 元に戻したい場合

## カスタマイズ

### 設定ファイルの変更

```bash
# neovim 設定
nvim configs/nvim/init.lua

# tmux 設定
nvim configs/tmux/tmux.conf

# starship 設定
nvim configs/starship.toml

# 変更を適用
home-manager switch --flake .#full-linux
```

### パッケージの追加

`modules/core.nix` を編集:

```nix
home.packages = with pkgs; [
  # 既存のパッケージ
  neovim
  tmux
  # 追加するパッケージ
  htop
  jq
];
```

```bash
# 適用
home-manager switch --flake .#full-linux
```

## WSL での利用

Windows Subsystem for Linux でも動作します:

```bash
# WSL2 Ubuntu など
# 通常の Linux と同じ手順でインストール

# 注意: systemd が有効な WSL2 が推奨
# /etc/wsl.conf に以下を追加:
# [boot]
# systemd=true
```
