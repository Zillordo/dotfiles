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
    firefox

    # tools
    bat
    ripgrep
    fzf
    libnotify
    killall
    zip
    unzip
    glib
    fnm

    # langs
    nodejs
    gjs
    bun
    cargo
    go
    gcc
    typescript
    eslint
  ];
}
