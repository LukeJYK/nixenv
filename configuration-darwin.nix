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
  fonts.packages = with pkgs; [
    iosevka
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
    nerd-fonts.zed-mono
    maple-mono.NF
  ];
  system.stateVersion = 6;
}
