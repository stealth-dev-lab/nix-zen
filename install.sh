#!/bin/sh
# nix-zen installer
# https://github.com/stealth-dev-lab/nix-zen
set -e

# Configuration
REPO_URL="https://github.com/stealth-dev-lab/nix-zen.git"
INSTALL_DIR="${HOME}/.nix-zen"
NIX_INSTALLER_URL="https://install.determinate.systems/nix"

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

# Print functions
info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

# Show usage
usage() {
    cat <<EOF
nix-zen installer

Usage: $0 [OPTIONS]

Options:
    --minimal      Install minimal profile (lightweight)
    --uninstall    Remove nix-zen (keeps Nix)
    --help         Show this help message

Examples:
    $0                 # Interactive install (full profile)
    $0 --minimal       # Install minimal profile
    $0 --uninstall     # Remove nix-zen
EOF
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "darwin" ;;
        *)       echo "unknown" ;;
    esac
}

# Check if Nix is installed
check_nix() {
    if command -v nix >/dev/null 2>&1; then
        return 0
    fi
    # Check common locations
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        return 0
    fi
    if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        return 0
    fi
    return 1
}

# Install Nix
install_nix() {
    info "Nix not found. Installing via Determinate Systems installer..."
    printf "\n"

    curl --proto '=https' --tlsv1.2 -sSf -L "$NIX_INSTALLER_URL" | sh -s -- install

    # Source Nix
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi

    success "Nix installed successfully"
}

# Enable flakes if not already enabled
enable_flakes() {
    nix_conf="$HOME/.config/nix/nix.conf"

    # Check if flakes are already enabled
    if nix flake --help >/dev/null 2>&1; then
        return 0
    fi

    info "Enabling Nix flakes..."
    mkdir -p "$(dirname "$nix_conf")"

    if [ -f "$nix_conf" ]; then
        if ! grep -q "experimental-features" "$nix_conf"; then
            echo "experimental-features = nix-command flakes" >> "$nix_conf"
        fi
    else
        echo "experimental-features = nix-command flakes" > "$nix_conf"
    fi

    success "Flakes enabled"
}

# Backup existing dotfiles
backup_dotfiles() {
    backup_suffix=".bak.$(date +%Y%m%d%H%M%S)"

    for file in .config/nvim .config/starship.toml .tmux.conf; do
        target="$HOME/$file"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            warn "Backing up existing $file"
            mv "$target" "${target}${backup_suffix}"
        fi
    done
}

# Select profile
select_profile() {
    os=$(detect_os)

    if [ "$MINIMAL" = "true" ]; then
        case "$os" in
            linux)  echo "minimal-linux" ;;
            darwin) echo "minimal-mac" ;;
        esac
        return
    fi

    printf "\n${BLUE}Select profile:${NC}\n"
    printf "  1) full    - Complete development environment (Recommended)\n"
    printf "  2) minimal - Lightweight, mobile-optimized\n"
    printf "Choice [1]: "
    read -r choice

    case "$choice" in
        2)
            case "$os" in
                linux)  echo "minimal-linux" ;;
                darwin) echo "minimal-mac" ;;
            esac
            ;;
        *)
            case "$os" in
                linux)  echo "full-linux" ;;
                darwin) echo "full-mac" ;;
            esac
            ;;
    esac
}

# Clone or update repository
setup_repo() {
    if [ -d "$INSTALL_DIR" ]; then
        info "Updating nix-zen repository..."
        git -C "$INSTALL_DIR" pull --ff-only
    else
        info "Cloning nix-zen repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
    success "Repository ready at $INSTALL_DIR"
}

# Apply configuration
apply_config() {
    profile="$1"
    info "Applying profile: $profile"
    printf "\n"

    cd "$INSTALL_DIR"
    nix run nixpkgs#home-manager -- switch --flake ".#${profile}"

    success "Configuration applied successfully!"
}

# Print success message
print_success() {
    profile="$1"
    printf "\n${GREEN}======================================${NC}\n"
    printf "${GREEN}  nix-zen installed successfully!${NC}\n"
    printf "${GREEN}======================================${NC}\n\n"
    printf "Profile: ${BOLD}%s${NC}\n" "$profile"
    printf "Config:  %s\n" "$INSTALL_DIR"
    printf "\n"
    printf "${YELLOW}Open a new terminal${NC} to start using nix-zen.\n"
    printf "\n"
    printf "Commands:\n"
    printf "  home-manager switch --flake %s#%s  # Re-apply\n" "$INSTALL_DIR" "$profile"
    printf "  home-manager rollback                       # Undo changes\n"
    printf "  home-manager generations                    # View history\n"
    printf "\n"
}

# Uninstall
uninstall() {
    info "Uninstalling nix-zen..."

    # Run home-manager uninstall if available
    if command -v home-manager >/dev/null 2>&1; then
        home-manager uninstall || true
    fi

    # Remove install directory
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        success "Removed $INSTALL_DIR"
    fi

    printf "\n"
    success "nix-zen uninstalled."
    printf "\n"
    printf "Note: Nix itself is still installed.\n"
    printf "To remove Nix completely: /nix/nix-installer uninstall\n"
    printf "\n"
}

# Main
main() {
    MINIMAL=false

    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                usage
                exit 0
                ;;
            --minimal)
                MINIMAL=true
                shift
                ;;
            --uninstall)
                uninstall
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    printf "${BOLD}nix-zen installer${NC}\n"
    printf "https://github.com/stealth-dev-lab/nix-zen\n\n"

    # Check OS
    os=$(detect_os)
    if [ "$os" = "unknown" ]; then
        error "Unsupported operating system"
        exit 1
    fi
    info "Detected OS: $os"

    # Check/Install Nix
    if ! check_nix; then
        install_nix
    else
        success "Nix is already installed"
    fi

    # Enable flakes
    enable_flakes

    # Select profile
    profile=$(select_profile)

    # Backup existing dotfiles
    backup_dotfiles

    # Setup repository
    setup_repo

    # Apply configuration
    apply_config "$profile"

    # Print success
    print_success "$profile"
}

main "$@"
