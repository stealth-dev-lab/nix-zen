# Nix-Zen

Lightweight Nix development environment for [stealth-dev-lab](https://github.com/stealth-dev-lab).

## Profiles

| Profile | Use Case | Description |
|---------|----------|-------------|
| `full` | Desktop / SSH development | Complete dev environment with all tools |
| `minimal` | Mobile (iPhone/iPad) | Lightweight with shortcuts & completions |

## Quick Start

```bash
# Clone
git clone https://github.com/stealth-dev-lab/nix-zen.git ~/work/stealth-dev-lab/nix-zen
cd ~/work/stealth-dev-lab/nix-zen

# Apply full profile (Linux)
home-manager switch --flake .#full-linux

# Apply minimal profile (Linux)
home-manager switch --flake .#minimal-linux

# For macOS (Apple Silicon)
home-manager switch --flake .#full-mac
home-manager switch --flake .#minimal-mac
```

## Structure

```
nix-zen/
├── flake.nix          # Entry point
├── modules/           # Feature modules
│   ├── core.nix      # Essential packages
│   ├── dev.nix       # Development tools
│   └── mobile.nix    # Mobile optimizations
├── profiles/          # Profile presets
│   ├── full.nix      # Full development
│   └── minimal.nix   # Mobile-optimized
└── configs/           # Config files
    ├── nvim/
    ├── tmux/
    └── starship.toml
```

## Mobile Shortcuts

| Alias | Command |
|-------|---------|
| `g` | git |
| `gs` | git status |
| `gc` | git commit |
| `ta` | tmux attach -t |
| `tl` | tmux list-sessions |
| `l` | eza -la |
| `e` | $EDITOR |

See [MOBILE_CHEATSHEET.md](docs/MOBILE_CHEATSHEET.md) for full list.

---

Part of [stealth-dev-lab](https://github.com/stealth-dev-lab).
