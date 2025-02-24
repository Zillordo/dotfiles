{ pkgs, ... }: {
  home.packages = with pkgs;
    with nodePackages_latest; [
      obsidian
      spotify
      whatsapp-for-linux
      vlc # video player
    ];
}
