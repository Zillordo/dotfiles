{ pkgs, ... }:
{
  xdg.desktopEntries = {
    "lf" = {
      name = "lf";
      noDisplay = true;
    };
  };

  home.packages = with pkgs; with nodePackages_latest; with gnome; [
    # gui
    obsidian
    spotify
    whatsapp-for-linux
    caprine-bin #facebook messanger app for linux
    gnome.gnome-bluetooth

    # tools
    bat
    ripgrep
    fzf
    libnotify
    killall
    zip
    unzip
    glib
    dust
    btop
    tldr
    tokei

    # some language tools needed for vim or other apps I use
    nodejs
    gjs
    cargo
    gcc
  ];
}
