{
  description = "yankai's setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05"; # keep same version as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nix-darwin }:
    let
      configuration =
        { pkgs, ... }:
        {
          # Determinate manages Nix itself, so nix-darwin must not
          nix.enable = false;

          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfree = true;

          # user that user-level options (system.defaults, homebrew) apply to
          system.primaryUser = "yankai";

          # system-wide packages, search with: nix search nixpkgs <name>
          environment.systemPackages = with pkgs; [
            git
            vim
          ];

          # git commit of this config, shown by darwin-version
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # do not change; read `darwin-rebuild changelog` first
          system.stateVersion = 6;
        };
    in
    {
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
