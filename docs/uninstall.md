# アンインストール

nix-zen や Nix を削除する手順です。段階的に説明します。

## レベル 1: 前の状態に戻す（ロールバック）

一番軽い操作。設定を変更前に戻すだけ。

```bash
# 1つ前の世代に戻す
home-manager rollback

# 確認
home-manager generations
```

**影響:**
- 前の設定に戻る
- Nix 自体は残る
- いつでも再適用可能

## レベル 2: nix-zen を無効化

home-manager の設定を解除。dotfiles のリンクが消える。

```bash
# home-manager を無効化
home-manager uninstall
```

**影響:**
- `~/.config/nvim`, `~/.tmux.conf` などのシンボリックリンクが削除
- インストールしたパッケージは PATH から消える
- `/nix/store` のファイルは残る（後で再利用可能）
- Nix 自体は残る

**元に戻すには:**
```bash
cd nix-zen
home-manager switch --flake .#full-linux
```

## レベル 3: Nix を完全削除

Nix 自体をシステムから削除。

### Determinate Systems Installer で入れた場合

```bash
/nix/nix-installer uninstall
```

これで完全に削除されます。

### 公式インストーラーで入れた場合

#### Linux (systemd)

```bash
# 1. Nix デーモン停止
sudo systemctl stop nix-daemon.socket
sudo systemctl stop nix-daemon.service
sudo systemctl disable nix-daemon.socket
sudo systemctl disable nix-daemon.service

# 2. サービスファイル削除
sudo rm /etc/systemd/system/nix-daemon.service
sudo rm /etc/systemd/system/nix-daemon.socket
sudo systemctl daemon-reload

# 3. Nix ファイル削除
sudo rm -rf /nix
sudo rm -rf /etc/nix
sudo rm -rf ~/.nix-*
sudo rm -rf ~/.cache/nix
sudo rm -rf ~/.local/state/nix

# 4. nixbld ユーザー/グループ削除 (オプション)
for i in $(seq 1 32); do
  sudo userdel nixbld$i 2>/dev/null
done
sudo groupdel nixbld 2>/dev/null

# 5. シェル設定から Nix を削除
# ~/.bashrc, ~/.zshrc から以下の行を削除:
#   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

#### macOS

```bash
# 1. Nix デーモン停止
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist

# 2. Nix ボリューム削除
sudo diskutil apfs deleteVolume /nix

# 3. /etc/synthetic.conf から nix 行を削除
sudo sed -i '' '/^nix$/d' /etc/synthetic.conf

# 4. fstab から Nix を削除
sudo vifs  # /nix 行を削除

# 5. Nix ファイル削除
sudo rm -rf /etc/nix
rm -rf ~/.nix-*
rm -rf ~/.cache/nix

# 6. nixbld ユーザー/グループ削除
for i in $(seq 1 32); do
  sudo dscl . -delete /Users/_nixbld$i 2>/dev/null
done
sudo dscl . -delete /Groups/nixbld 2>/dev/null

# 7. シェル設定からNixを削除
# /etc/bashrc, /etc/zshrc の Nix 関連行を削除
```

## 削除後の確認

```bash
# Nix が消えていることを確認
which nix          # 見つからないはず
ls /nix            # 存在しないはず
echo $PATH | grep nix  # 出力なしのはず
```

## よくある質問

### Q: ロールバックと無効化の違いは？

| 操作 | 設定 | パッケージ | Nix |
|------|------|-----------|-----|
| ロールバック | 前の世代 | 利用可能 | 残る |
| 無効化 | 解除 | PATH から消える | 残る |
| 完全削除 | 解除 | 削除 | 削除 |

### Q: /nix/store が大きい

```bash
# 使用量確認
du -sh /nix/store

# 古い世代と未使用パッケージを削除
nix-collect-garbage -d

# より積極的に削除
nix-store --gc --print-roots
nix-collect-garbage --delete-older-than 7d
```

### Q: 一部の設定だけ戻したい

```bash
# 例: nvim の設定だけ元に戻す
rm ~/.config/nvim
# その後、自分の設定を配置
```

### Q: 再インストールしたい

```bash
# 削除後、クイックスタートの手順で再インストール
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# ターミナル再起動後
cd nix-zen
nix run nixpkgs#home-manager -- switch --flake .#full-linux
```

## まとめ

| やりたいこと | コマンド |
|-------------|---------|
| 設定を1つ前に戻す | `home-manager rollback` |
| nix-zen を無効化 | `home-manager uninstall` |
| Nix を完全削除 | `/nix/nix-installer uninstall` または手動手順 |

**迷ったらまず `home-manager rollback` から試してください。**
