{
  description = "Nix-Zen: Lightweight Nix development environment for stealth-dev-lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    # Path to nix-zen root (for config files)
    nixZenPath = self.outPath;

    # Helper function to create home-manager configuration
    mkHome = { system, profile, username, homeDirectory, includeConfigs ? true }:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit nixZenPath; };
        modules = [
          # Import the selected profile
          profile

          # Base configuration
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
            home.stateVersion = "23.11";

            # Let Home Manager manage itself
            programs.home-manager.enable = true;
          }
        ] ++ lib.optionals includeConfigs [
          # Config files management (nvim, tmux, starship)
          ./modules/configs.nix
        ];
      };
    # Default user config (override via extraSpecialArgs if needed)
    defaultUser = {
      linux = { username = "dev-user"; homeDirectory = "/home/dev-user"; };
      darwin = { username = "user"; homeDirectory = "/Users/user"; };
      container = { username = "root"; homeDirectory = "/root"; };
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

      # Container profile - For testing in containers (runs as root)
      # Usage: home-manager switch --flake .#container
      container = mkHome {
        system = "x86_64-linux";
        profile = ./profiles/minimal.nix;
        inherit (defaultUser.container) username homeDirectory;
        includeConfigs = false;  # Skip config files in container
      };

      # Container profile with configs - For full testing in containers
      # Usage: home-manager switch --flake .#container-full
      container-full = mkHome {
        system = "x86_64-linux";
        profile = ./profiles/full.nix;
        inherit (defaultUser.container) username homeDirectory;
        includeConfigs = true;  # Include config files
      };
    };
  };
}
