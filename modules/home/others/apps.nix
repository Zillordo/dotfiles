{ pkgs, ... }: {
  home.packages = with pkgs;
    with nodePackages_latest; [
      obsidian
      spotify
      whatsapp-for-linux
      caprine-bin # facebook messanger app for linux
      vlc # video player
    ];
}
