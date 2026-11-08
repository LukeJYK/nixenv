# nixenv

Declarative setup for my MacBook (Apple Silicon), built with
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager) on nixpkgs 26.05.

## Layout

| File | What it holds |
|---|---|
| `flake.nix` | Inputs (nixpkgs 26.05, nixpkgs-unstable, nix-darwin, home-manager) and the `MacBook` config |
| `configuration-darwin.nix` | System level: system packages, fonts, users |
| `home-darwin.nix` | User level (home-manager): user packages |

Packages come from nixpkgs 26.05 by default. Use `pkgs.unstable.<name>` to get the newest version from nixpkgs-unstable.

## Tools

**System packages** (`configuration-darwin.nix`)

| Tool | Purpose |
|---|---|
| ripgrep (`rg`) | Fast text search |
| fastfetch | System info |

**User packages** (`home-darwin.nix`)

| Tool | Purpose |
|---|---|
| btop | Resource monitor |
| tmux | Terminal multiplexer |
| chezmoi | Dotfile manager |
| mise | Version manager for CLI tools (from unstable) |
| WezTerm | Terminal emulator (GUI) |

**Fonts** (`configuration-darwin.nix`)

Iosevka, Iosevka Nerd Font, VictorMono Nerd Font, ZedMono Nerd Font, Maple Mono NF

## Install on a new Mac

1. Install Nix with the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer),
   then open a new terminal:

   ```sh
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone this repo and run the first switch (this also installs `darwin-rebuild`):

   ```sh
   git clone https://github.com/LukeJYK/nixenv ~/nixenv
   cd ~/nixenv
   sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#MacBook
   ```

Determinate manages Nix itself, so `configuration-darwin.nix` sets `nix.enable = false`.
Don't set `nix.settings` options there; put Nix settings in `/etc/nix/nix.custom.conf` instead.

## Daily use

```sh
sudo darwin-rebuild switch --flake .#MacBook   # apply changes
darwin-rebuild build --flake .#MacBook         # build only, to check the config
nix flake update                               # update all inputs, then switch
sudo darwin-rebuild --rollback                 # go back to the previous generation
```

New files must be added with `git add` before the flake can see them.

## Uninstall

```sh
sudo darwin-uninstaller          # remove nix-darwin and home-manager first
/nix/nix-installer uninstall     # then remove Nix
```
