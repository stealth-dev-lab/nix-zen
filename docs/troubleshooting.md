# トラブルシューティング

よくある問題と解決方法です。

## インストール時の問題

### `nix` コマンドが見つからない

**症状:**
```bash
$ nix --version
command not found: nix
```

**原因:** シェルの設定が読み込まれていない

**解決:**
```bash
# ターミナルを再起動
# または
source /etc/profile
# または
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### Flakes が使えない

**症状:**
```bash
$ nix flake show
error: experimental Nix feature 'flakes' is disabled
```

**解決:**
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### home-manager コマンドがない

**症状:**
```bash
$ home-manager switch
command not found: home-manager
```

**解決:** `nix run` 経由で実行
```bash
nix run nixpkgs#home-manager -- switch --flake .#full-linux
```

初回適用後は `home-manager` が PATH に追加されます。

## 適用時の問題

### ファイルが既に存在する

**症状:**
```
error: Existing file '...' is in the way of '/nix/store/...'
```

**原因:** 既存の dotfiles と競合

**解決:**
```bash
# 競合するファイルをバックアップして削除
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.tmux.conf ~/.tmux.conf.bak

# 再度適用
home-manager switch --flake .#full-linux
```

### ビルドエラー

**症状:**
```
error: builder for '...' failed
```

**解決:**
```bash
# キャッシュをクリアして再試行
nix-collect-garbage
home-manager switch --flake .#full-linux

# それでもダメなら flake.lock を更新
nix flake update
home-manager switch --flake .#full-linux
```

### ダウンロードが遅い

**症状:** パッケージのダウンロードに非常に時間がかかる

**解決:** 日本のミラーを使用（オプション）
```bash
# ~/.config/nix/nix.conf に追加
substituters = https://cache.nixos.org https://nix-cache.s3.amazonaws.com
```

## 実行時の問題

### 設定が反映されない

**症状:** `home-manager switch` したが変更が反映されない

**解決:**
```bash
# 新しいターミナルを開く
# または
source ~/.bashrc  # bash の場合
source ~/.zshrc   # zsh の場合

# それでもダメなら
home-manager switch --flake .#full-linux -b backup
```

### neovim のプラグインが動かない

**症状:** neovim を起動してもプラグインが読み込まれない

**解決:**
```bash
# neovim 内で
:checkhealth

# プラグインを再インストール
:Lazy sync
```

### tmux の設定が効かない

**症状:** tmux の設定が反映されない

**解決:**
```bash
# tmux を完全に終了
tmux kill-server

# 再度起動
tmux
```

### PATH にツールが見つからない

**症状:** `home-manager switch` 後もコマンドが見つからない

**解決:**
```bash
# 現在の PATH を確認
echo $PATH | tr ':' '\n' | grep nix

# home-manager のパスを確認
ls ~/.nix-profile/bin/

# シェルを再起動
exec $SHELL
```

## 世代管理

### 前の状態に戻したい

```bash
# 1つ前に戻す
home-manager rollback

# 世代一覧を見る
home-manager generations

# 出力例:
# 2024-02-26 12:00 : id 5 -> /nix/store/xxx-home-manager-generation
# 2024-02-25 10:00 : id 4 -> /nix/store/yyy-home-manager-generation

# 特定の世代に戻す
/nix/store/yyy-home-manager-generation/activate
```

### 古い世代を削除してディスク容量を空ける

```bash
# 古い世代を削除
home-manager expire-generations "-7 days"

# ゴミ収集
nix-collect-garbage -d

# 使用容量確認
du -sh /nix/store
```

## macOS 固有の問題

### コマンドラインツールのエラー

**症状:**
```
xcrun: error: invalid active developer path
```

**解決:**
```bash
xcode-select --install
```

### Rosetta 関連 (Apple Silicon)

**症状:** x86_64 パッケージがビルドできない

**解決:**
```bash
# Rosetta インストール
softwareupdate --install-rosetta
```

## それでも解決しない場合

### デバッグ情報の収集

```bash
# Nix バージョン
nix --version

# 現在の世代
home-manager generations | head -5

# 最後のビルドログ
nix log /nix/store/xxx-home-manager-generation

# システム情報
uname -a
```

### クリーンな状態からやり直す

```bash
# 1. home-manager を無効化
home-manager uninstall

# 2. nix-zen を再適用
home-manager switch --flake .#full-linux
```

### 完全にやり直す

[アンインストール](uninstall.md) を参照して Nix を削除し、最初からやり直してください。
