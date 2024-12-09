{ pkgs, ... }: {
  home.packages = with pkgs;
    with nodePackages_latest;
    with gnome; [
      obsidian
      spotify
      whatsapp-for-linux
      caprine-bin # facebook messanger app for linux
      totem # video player from gnome
      zoom-us
    ];
}
