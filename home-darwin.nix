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
    # version manager
    unstable.mise
    # macos gui
    wezterm
    # zsh; .zshrc from chezmoi sources these from /etc/profiles/per-user/$USER/share
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    openssh
    starship
    # formatters; treefmt reads treefmt.toml at the repo root
    treefmt
    nixfmt
  ];
}
