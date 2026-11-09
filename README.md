# nixenv

Declarative setup for my MacBooks (Apple Silicon), built with
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager) on nixpkgs 26.05.

## Machines

Both Macs share `configuration-darwin.nix` and `home-darwin.nix`. Each one has a
`hosts/<name>/default.nix` for what differs, which is only the login user right now.

| Config | Machine | User |
|---|---|---|
| `macbook-1` | Personal MacBook | `yankai` |
| `macbook-2` | Lab MacBook | `jiang.yank` |

`build.sh` finds the current Mac by login user. It reads the `system.primaryUser = "...";` line
in each host file and picks the host whose user matches `id -un`. That means every Mac needs
its own login user, and that line must stay on a single line in this exact form.

To add another Mac:

1. Create `hosts/<name>/default.nix` that sets `system.primaryUser`.
2. Add `<name> = mkDarwinSystem ./hosts/<name>/default.nix;` to `darwinConfigurations` in `flake.nix`.
3. Run `git add hosts/<name>` so the flake can see the new file.

## Layout

| File | What it holds |
|---|---|
| `flake.nix` | Inputs (nixpkgs 26.05, nixpkgs-unstable, nix-darwin, home-manager), `mkDarwinSystem`, and one config per Mac |
| `hosts/<name>/default.nix` | Per-machine settings: the login user (`system.primaryUser`) |
| `configuration-darwin.nix` | System level, shared by all Macs: fonts, users, linked share paths |
| `home-darwin.nix` | User level (home-manager): user packages |
| `build.sh` | Builds, switches, or updates. It detects the current Mac on its own |
| `run-before-commit.sh` | Checks to run before a commit: untracked `.nix` files, formatting, every Mac builds |
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
| Obsidian | Markdown notes app (GUI, unfree, from unstable) |
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

2. Clone this repo and run the first switch:

   ```sh
   git clone https://github.com/LukeJYK/nixenv ~/nixenv
   cd ~/nixenv
   ./build.sh switch
   ```

   `build.sh` picks `macbook-1` or `macbook-2` from your login user. `darwin-rebuild` isn't
   installed yet on a new Mac, so the script runs it through `nix run`. That first switch
   installs it for later runs.

Determinate manages Nix itself, so `configuration-darwin.nix` sets `nix.enable = false`.
Don't set `nix.settings` options there; put Nix settings in `/etc/nix/nix.custom.conf` instead.

## Daily use

Run `build.sh` without `sudo`. It asks for `sudo` itself when it switches.

```sh
./build.sh build                 # build this Mac only, then list the packages that would change
./build.sh switch                # build and switch this Mac
./build.sh build all             # build every Mac, to check that a shared change breaks none
./build.sh build macbook-2       # build one specific Mac
./build.sh update [input...]     # update flake.lock: every input, or only the ones named
sudo darwin-rebuild --rollback   # go back to the previous generation
```

`switch` only ever switches the Mac you're on. It refuses to put another Mac's config on this one.
`build` and `switch` never change `flake.lock`. Only `update` does.

New files must be added with `git add` before the flake can see them.

### A typical change

```sh
# edit home-darwin.nix, configuration-darwin.nix, ...
./build.sh build                 # check it builds and see what changes
./build.sh switch
./run-before-commit.sh           # format, then build every Mac
git add -A && git commit
```

On the other Mac, run `git pull` and then `./build.sh switch`.

## Updating flake.lock

`flake.lock` pins every input to an exact commit. As long as it's committed, both Macs get
exactly the same package versions.

You **must** update it after you add an input to `flake.nix` or change an input's URL. Until
you do, builds fail and ask for it. Lock only that input:

```sh
./build.sh update <input>
```

Otherwise updating is **optional**. Do it when you want newer packages or security fixes, for
example every few weeks. Editing packages, host files or scripts never needs it.

```sh
./build.sh update                    # every input
./build.sh update nixpkgs-unstable   # only unstable
./build.sh build                     # list which packages changed version
./build.sh switch
git add flake.lock && git commit -m "update flake inputs"
```

`nix flake metadata` lists each input with its "Last modified" date.

## Before you commit

```sh
./run-before-commit.sh
```

The script does three things:

1. It stops if there are untracked `.nix` files, because the flake can't see them.
2. It runs `treefmt`, which formats every `.nix` file with nixfmt.
3. It runs `./build.sh build all` to check that every Mac still builds.

The script doesn't commit anything. `treefmt` may rewrite files, so look at the `git status`
it prints at the end and stage what changed.

## Uninstall

```sh
sudo darwin-uninstaller          # remove nix-darwin and home-manager first
/nix/nix-installer uninstall     # then remove Nix
```
