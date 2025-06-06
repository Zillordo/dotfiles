{ unstable, pkgs, ... }: {
  # imports = [ ./steam.nix ];

  environment.systemPackages = with pkgs; [
    home-manager
    unstable.davinci-resolve
    neovim
    git
    wget
    lightworks
  ];
}

