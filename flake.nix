{
  description = "Nix-Zen: Lightweight Nix development environment for stealth-dev-lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    # Helper function to create home-manager configuration
    mkHome = { system, profile, username, homeDirectory }:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          # Import the selected profile
          profile

          # Base configuration
          ({ lib, ... }: {
            home.username = username;
            home.homeDirectory = homeDirectory;
            home.stateVersion = "23.11";

            # Let Home Manager manage itself
            programs.home-manager.enable = true;

            # Symlink configs from nix-zen/configs/
            home.activation.linkConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
              NIX_ZEN_DIR="$HOME/work/stealth-dev-lab/nix-zen"

              # nvim config
              if [ -d "$NIX_ZEN_DIR/configs/nvim" ] && [ ! -e "$HOME/.config/nvim" ]; then
                echo "Linking nvim config..."
                ln -sfn "$NIX_ZEN_DIR/configs/nvim" "$HOME/.config/nvim"
              fi

              # tmux config
              mkdir -p "$HOME/.config/tmux"
              if [ -f "$NIX_ZEN_DIR/configs/tmux/tmux.conf" ] && [ ! -e "$HOME/.config/tmux/tmux.conf" ]; then
                echo "Linking tmux config..."
                ln -sfn "$NIX_ZEN_DIR/configs/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
              fi

              # starship config
              if [ -f "$NIX_ZEN_DIR/configs/starship.toml" ] && [ ! -e "$HOME/.config/starship.toml" ]; then
                echo "Linking starship config..."
                ln -sfn "$NIX_ZEN_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
              fi
            '';
          })
        ];
      };
    # Default user config (override via extraSpecialArgs if needed)
    defaultUser = {
      linux = { username = "dev-user"; homeDirectory = "/home/dev-user"; };
      darwin = { username = "user"; homeDirectory = "/Users/user"; };
    };
  in {
    homeConfigurations = {
      # Full profile - Complete development environment
      # Usage: home-manager switch --flake .#full-linux
      full-linux = mkHome {
        system = "x86_64-linux";
        profile = ./profiles/full.nix;
        inherit (defaultUser.linux) username homeDirectory;
      };

      full-mac = mkHome {
        system = "aarch64-darwin";
        profile = ./profiles/full.nix;
        inherit (defaultUser.darwin) username homeDirectory;
      };

      # Minimal profile - Mobile-optimized
      # Usage: home-manager switch --flake .#minimal-linux
      minimal-linux = mkHome {
        system = "x86_64-linux";
        profile = ./profiles/minimal.nix;
        inherit (defaultUser.linux) username homeDirectory;
      };

      minimal-mac = mkHome {
        system = "aarch64-darwin";
        profile = ./profiles/minimal.nix;
        inherit (defaultUser.darwin) username homeDirectory;
      };
    };
  };
}
