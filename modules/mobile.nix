# Mobile module - Optimizations for mobile (iPhone/iPad) access
{ pkgs, lib, ... }:

{
  # Packages for mobile experience
  home.packages = with pkgs; [
    zsh-completions
    zoxide        # Smart cd command
    # zsh-fzf-tab disabled due to GLIBC compatibility issues
  ];

  programs.zsh = {
    # Shell aliases for quick access
    shellAliases = {
      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate -20";
      lg = "lazygit";  # Git TUI

      # tmux shortcuts
      ta = "tmux attach -t";
      tl = "tmux list-sessions";
      tn = "tmux new -s";
      tk = "tmux kill-session -t";

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # File listing (using eza with colors)
      l = "eza -la --color=always";
      ll = "eza -l --color=always";
      la = "eza -la --color=always";
      lt = "eza -laT --level=2 --color=always";
      ls = "ls --color=auto";  # Fallback for standard ls

      # Quick edits
      e = "$EDITOR";
      v = "nvim";

      # Build shortcuts
      mk = "make";
      mkj = "make -j$(nproc)";

      # Docker/Podman
      d = "docker";
      dc = "docker compose";
      p = "podman";
      pc = "podman-compose";

      # Misc
      c = "clear";
      h = "history";
      q = "exit";
      grep = "grep --color=auto";
    };

    initContent = ''
      # History settings for quick recall
      HISTSIZE=10000
      SAVEHIST=10000
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt INC_APPEND_HISTORY

      # Enable colors
      export CLICOLOR=1
      export TERM=''${TERM:-xterm-256color}

      # Quick directory jumping with z
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # ===== Keybindings =====
      bindkey -e  # Emacs-style keybindings
      bindkey '^P' up-line-or-history
      bindkey '^N' down-line-or-history
      bindkey '^A' beginning-of-line
      bindkey '^E' end-of-line
      bindkey '^F' autosuggest-accept
      bindkey '^[f' forward-word

      # Ctrl+R for fuzzy history search
      bindkey '^R' fzf-history-widget
    '';
  };

  # FZF configuration
  home.sessionVariables = {
    FZF_DEFAULT_OPTS = ''
      --height 40%
      --layout=reverse
      --border
      --inline-info
      --color=fg:#d4d4d4,bg:#1e1e1e,hl:#569cd6
      --color=fg+:#d4d4d4,bg+:#264f78,hl+:#4ec9b0
      --color=info:#ce9178,prompt:#4ec9b0,pointer:#c586c0
      --color=marker:#4ec9b0,spinner:#ce9178,header:#569cd6
    '';
  };
}
