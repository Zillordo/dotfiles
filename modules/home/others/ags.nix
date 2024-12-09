{ inputs, pkgs, config, ... }: {
  imports = [ inputs.ags.homeManagerModules.default ];

  home.packages = with pkgs; [
    bun
    dart-sass
    fd
    brightnessctl
    swww
    inputs.matugen.packages.${system}.default
    slurp
    wf-recorder
    wl-clipboard
    wayshot
    swappy
    hyprpicker
    pavucontrol
    networkmanager
    gtk3
    networkmanagerapplet
  ];

  programs.ags = {
    enable = true;
    configDir = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/dotfiles/dotfiles/ags";
    extraPackages = with pkgs; [ accountsservice ];
  };
}
