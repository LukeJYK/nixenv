# nixenv

Nix setup for macOS (MacBook). This repo will hold a declarative macOS setup built with
[nix-darwin](https://github.com/nix-darwin/nix-darwin).

## Step 1: Install Nix

Install Nix with the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer):

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal, then check that it works:

```sh
nix --version
nix run nixpkgs#hello
```

Flakes and `nix-command` are already turned on, so you don't need to edit `nix.conf`.

## Step 2: nix-darwin (next)

Not set up yet. Note: Determinate already manages the Nix daemon, so the nix-darwin config
will need:

```nix
nix.enable = false;
```

## Uninstall

```sh
/nix/nix-installer uninstall
```

This removes Nix, the `/nix` volume, the daemon, and the related shell profile changes.
If nix-darwin is installed later, uninstall it first:

```sh
sudo darwin-uninstaller
```
