# Full profile - Complete development environment
# Use for: Desktop, SSH full development
{ ... }:

{
  imports = [
    ../modules/core.nix
    ../modules/dev.nix
    ../modules/mobile.nix
  ];

  # Profile identifier
  home.sessionVariables = {
    NIX_ZEN_PROFILE = "full";
  };
}
