{ pkgs, ... }: {
  imports = [ ./lf.nix ./tmux.nix ./zoxide.nix ./git.nix ./direnv.nix ];

  xdg.desktopEntries = {
    "lf" = {
      name = "lf";
      noDisplay = true;
    };
  };

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
    ];
}
