{ config, pkgs, ... }:
let
  # set per machine in hosts/<name>/default.nix
  username = config.system.primaryUser;
in
{
  # Determinate Nix manages nix itself; nix-darwin must not touch it
  nix.enable = false;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
  home-manager.users.${username} = ./home-darwin.nix;

  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = with pkgs; [
    iosevka
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
    nerd-fonts.zed-mono
    maple-mono.NF
  ];
  system.stateVersion = 6;

  environment.pathsToLink = [
    "/share/oh-my-zsh"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

}
