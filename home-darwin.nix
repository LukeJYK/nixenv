{ pkgs, ... }:
{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # cli
    btop
    # multiplexing
    tmux
    # dotfiles
    chezmoi
    # macos gui
    wezterm
  ];
}
