{ pkgs, ... }: {
  imports = [ ./direnv.nix ./git.nix ./tmux.nix ./zoxide.nix ./yazi.nix ];

  home.packages = with pkgs;
    with nodePackages_latest;
    with gnome; [
      bat
      ripgrep
      fzf
      libnotify
      killall
      xorg.xkill
      zip
      unzip
      glib
      # summary of folder/file sizes
      dust
      # system proccess, disk, network usage
      btop
      # tldr for man pages
      tldr
      # prints stats about language usage
      tokei
      # better list tool
      eza

      # some language tools needed for vim or other apps I use
      nodejs
      gjs
      cargo
      gcc

      netcat-openbsd
    ];
}

