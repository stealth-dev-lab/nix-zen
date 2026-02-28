# nix-zen container for trying before installing
FROM docker.io/nixos/nix:latest

# Enable flakes
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Remove conflicting packages
RUN nix-env -e man-db git-minimal wget || true

# Install home-manager
RUN nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && \
    nix-channel --update

# Copy nix-zen configuration
COPY . /nix-zen
WORKDIR /nix-zen

# Install home-manager and apply full configuration for best experience
RUN nix-shell '<home-manager>' -A install && \
    home-manager switch --flake .#container-full

# Set zsh as default shell
ENV SHELL=/root/.nix-profile/bin/zsh
WORKDIR /root
CMD ["/root/.nix-profile/bin/zsh"]
