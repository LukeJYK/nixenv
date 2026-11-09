{ config, pkgs, ... }:
{
  # Determinate Nix manages nix itself; nix-darwin must not touch it
  nix.enable = false;

  users.users.yankai = {
    name = "yankai";
    home = "/Users/yankai";
  };
  system.primaryUser = "yankai";

  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = with pkgs; [
    iosevka
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
    nerd-fonts.zed-mono
    maple-mono.NF
  ];
  system.stateVersion = 6;

  launchd.user.agents.aerospace = {
    command = "${pkgs.unstable.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
    path = [
      "/etc/profiles/per-user/yankai/bin"
      config.environment.systemPath
    ];
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  environment.pathsToLink = [
    "/share/oh-my-zsh"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

}
