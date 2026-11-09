{ pkgs, ... }:
{
  # Determinate Nix manages nix itself; nix-darwin must not touch it
  nix.enable = false;

  users.users.yankai = {
    name = "yankai";
    home = "/Users/yankai";
  };
  system.primaryUser = "yankai";

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

