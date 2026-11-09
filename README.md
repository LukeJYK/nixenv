# nixenv

Declarative setup for my MacBook (Apple Silicon), built with
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager) on nixpkgs 26.05.

## Layout

| File | What it holds |
|---|---|
| `flake.nix` | Inputs (nixpkgs 26.05, nixpkgs-unstable, nix-darwin, home-manager) and the `MacBook` config |
| `configuration-darwin.nix` | System level: fonts, users, linked share paths |
| `home-darwin.nix` | User level (home-manager): user packages |
| `treefmt.toml` | Formatter config: `treefmt` formats every `.nix` file with nixfmt |

Packages come from nixpkgs 26.05 by default. Use `pkgs.unstable.<name>` to get the newest version from nixpkgs-unstable.

## Tools

All packages are installed per user through home-manager (`home-darwin.nix`), into
`/etc/profiles/per-user/$USER`. There are no system-wide packages.

| Tool | Purpose |
|---|---|
| btop | Resource monitor |
| tmux | Terminal multiplexer |
| chezmoi | Dotfile manager |
| mise | Version manager for CLI tools (from unstable) |
| WezTerm | Terminal emulator (GUI) |
| openssh | SSH client and tools |
| oh-my-zsh | Zsh framework |
| zsh-autosuggestions | Suggests commands from history as you type |
| zsh-syntax-highlighting | Highlights commands as you type |
| starship | Shell prompt |
| treefmt | Runs formatters over the repo, configured in `treefmt.toml` |
| nixfmt | Formatter for `.nix` files |

The zsh packages are only installed here. `.zshrc` comes from chezmoi and loads them from
`/etc/profiles/per-user/$USER/share`. `configuration-darwin.nix` links those `share`
directories through `environment.pathsToLink`.

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

## Formatting

Run `treefmt` in the repo root before you commit. It formats every `.nix` file with nixfmt.

## Uninstall

```sh
sudo darwin-uninstaller          # remove nix-darwin and home-manager first
/nix/nix-installer uninstall     # then remove Nix
```
