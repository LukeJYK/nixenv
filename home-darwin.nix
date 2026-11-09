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
    unstable.aerospace
    sketchybar
    wezterm
    unstable.obsidian # unfree; unstable has allowUnfree, stable does not
    # zsh; .zshrc from chezmoi sources these from /etc/profiles/per-user/$USER/share
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    openssh
    starship
    # formatters; treefmt reads treefmt.toml at the repo root
    treefmt
    nixfmt
    # lua tooling; lua-language-server and stylua come from mise
    lua5_4
    lua54Packages.luacheck # not a top-level attr; match lua5_4 above

    #unstable.aerospace # 26.05's 0.20.3 ignores after-startup-command; 0.21.x works
    #sketchybar

  ];
}
