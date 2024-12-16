{ inputs, pkgs, ... }: {
  # imports = [ ./steam.nix ];

  environment.systemPackages = with pkgs; [ home-manager neovim git wget ];
}

