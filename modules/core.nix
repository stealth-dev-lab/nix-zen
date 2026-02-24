# Core module - Essential packages for all profiles
{ pkgs, lib, ... }:

{
  # Essential packages
  home.packages = with pkgs; [
    # Version control
    git
    gh
    lazygit

    # Search tools
    ripgrep
    fd
    fzf

    # Network tools
    curl
    wget
    jq

    # System utilities
    htop
    tree
    bat      # cat with syntax highlighting
    eza      # modern ls

    # Shell
    tmux
    starship
    direnv
    nix-direnv
  ];

  # PATH configuration
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };

  # zsh configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Initialize starship prompt
    initContent = ''
      eval "$(starship init zsh)"
    '';
  };

  # direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # fzf integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
