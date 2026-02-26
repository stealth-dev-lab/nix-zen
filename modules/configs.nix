# Configs module - Manages dotfiles via home.file
# This replaces the old home.activation approach with proper home-manager integration
{ config, lib, pkgs, nixZenPath, ... }:

{
  # nvim configuration (directory)
  home.file.".config/nvim" = {
    source = "${nixZenPath}/configs/nvim";
    recursive = true;
  };

  # tmux configuration
  home.file.".config/tmux/tmux.conf" = {
    source = "${nixZenPath}/configs/tmux/tmux.conf";
  };

  # starship configuration
  home.file.".config/starship.toml" = {
    source = "${nixZenPath}/configs/starship.toml";
  };
}
