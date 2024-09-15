{ inputs, pkgs, ... }: {
  imports = [ ./steam.nix ];

  environment.systemPackages = with pkgs; [
    home-manager
    neovim
    git
    wget
    # TODO: zen browser (remove when normal support is available)
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
}

