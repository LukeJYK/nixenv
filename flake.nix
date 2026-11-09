{
  description = "yankai's macbook setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05"; # keep home manager same version as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05"; # keep nix-darwin same version as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      darwinConfigurations = {
        MacBook = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            {
              nixpkgs.hostPlatform = "aarch64-darwin";
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import inputs.nixpkgs-unstable {
                    system = prev.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }

            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.yankai = ./home-darwin.nix;
            }
            ./configuration-darwin.nix
          ];
        };
      };
    };
}
