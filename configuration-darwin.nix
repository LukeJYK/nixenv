{ pkgs, ... }:
{
  # Determinate Nix manages nix itself; nix-darwin must not touch it
  nix.enable = false;

  users.users.yankai = {
    name = "yankai";
    home = "/Users/yankai";
  };
  system.primaryUser = "yankai";

  environment.systemPackages = [
    pkgs.ripgrep
    pkgs.fastfetch
  ];

  system.stateVersion = 6;
}
