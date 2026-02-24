# Minimal profile - Mobile-optimized lightweight environment
# Use for: iPhone/iPad access, quick SSH sessions
{ pkgs, ... }:

{
  imports = [
    ../modules/core.nix
    ../modules/mobile.nix
  ];

  # Lightweight neovim (basic config only)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Profile identifier
  home.sessionVariables = {
    NIX_ZEN_PROFILE = "minimal";
  };
}
