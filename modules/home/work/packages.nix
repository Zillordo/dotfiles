{ pkgs, ... }: {
  home.packages = with pkgs;
    with nodePackages_latest;
    with gnome; [
      slack
      devbox
      dbeaver-bin
    ];
}
