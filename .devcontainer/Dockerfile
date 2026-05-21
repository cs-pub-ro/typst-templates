FROM ubuntu:24.04

# Install sudo and basic tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        sudo curl ca-certificates xz-utils git && \
    rm -rf /var/lib/apt/lists/*

# Give the existing 'ubuntu' user sudo (optional: passwordless)
RUN usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 440 /etc/sudoers.d/ubuntu

# From here on, run as 'ubuntu'
RUN mkdir -p /vscode && chown ubuntu:ubuntu /vscode && \
    mkdir -p /root/lib/glibc/lib && chmod -R a+rX /root && \
    ln -s /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /root/lib/glibc/lib/ld-linux-x86-64.so.2

USER ubuntu
WORKDIR /home/ubuntu

# Single-user Nix install for this user
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Make Nix available and enable flakes/new CLI by default
ENV PATH=/home/ubuntu/.nix-profile/bin:${PATH}
ENV NIX_CONFIG="experimental-features = nix-command flakes"

# Workspace where VS Code will mount your repo
WORKDIR /workspace

# Copy flake definition (and lock file if present)
COPY flake.nix flake.lock* ./

# Build the typst-runtime closure from the flake
RUN nix build .#typst-runtime --out-link /tmp/typst-runtime && \
    mkdir -p /home/ubuntu/.typst-runtime && \
    cp -R /tmp/typst-runtime/* /home/ubuntu/.typst-runtime

# Use Typst runtime tools first, then Nix profile, then base PATH
ENV PATH=/home/ubuntu/.typst-runtime/bin:${PATH}

WORKDIR /workspace
CMD ["bash"]