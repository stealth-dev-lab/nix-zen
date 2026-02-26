# Development module - Full development environment
{ pkgs, lib, config, ... }:

{
  # Development packages
  home.packages = with pkgs; [
    # Languages
    nodejs
    jdk17
    kotlin
    kotlin-language-server
    ktlint
    python3

    # Container tools
    podman

    # Build tools
    gnumake
    cmake

    # Security / Auth
    pass
    gnupg
    pinentry-curses
  ];

  # Java configuration
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk17}";
  };

  # neovim with full configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # npm global packages path
  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  # Install AI CLI tools via npm
  home.activation.installNpmGlobal = lib.hm.dag.entryAfter ["installPackages"] ''
    NPM_BIN="${pkgs.nodejs}/bin/npm"
    if [ -x "$NPM_BIN" ]; then
      export PATH="${pkgs.nodejs}/bin:$PATH"
      NPM_PREFIX="$HOME/.npm-global"
      mkdir -p "$NPM_PREFIX"
      "$NPM_BIN" config set prefix "$NPM_PREFIX" >/dev/null 2>&1

      for pkg in @anthropic-ai/claude-code @openai/codex @google/gemini-cli; do
        if ! "$NPM_BIN" list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Installing $pkg via npm..."
          "$NPM_BIN" install -g "$pkg" || true
        fi
      done
    fi
  '';
}
