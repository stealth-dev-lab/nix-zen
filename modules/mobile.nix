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
      glog = "git log --oneline -20";

      # tmux shortcuts
      ta = "tmux attach -t";
      tl = "tmux list-sessions";
      tn = "tmux new -s";
      tk = "tmux kill-session -t";

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # File listing (using eza if available)
      l = "eza -la";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza -laT --level=2";

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
    };

    initContent = ''
      # History settings for quick recall
      HISTSIZE=10000
      SAVEHIST=10000
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt SHARE_HISTORY

      # Quick directory jumping with z
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # Ctrl+R for fuzzy history search
      bindkey '^R' fzf-history-widget
    '';
  };
}
