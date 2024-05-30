{
  inputs,
  username,
  pkgs,
  ...
}: 
let
  homeDirectory = "/home/${username}";
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule
    ../modules/home/zoxide.nix
    ../modules/home/zsh.nix
    ../modules/home/neovim.nix
    #../modules/home/hyprland.nix
    ../modules/home/starship.nix
    ../modules/home/git.nix
    ../modules/home/tmux.nix
    ../modules/home/packages.nix
    ../modules/home/lf.nix
    ../modules/home/browsers/default.nix
    ../modules/home/browsers/brave.nix
    #../modules/home/ags.nix
    ../modules/home/direnv.nix
    ../modules/home/terminals/kitty.nix
    #../modules/home/rofi.nix
    ../modules/home/work/packages.nix
  ];

  news.display = "show";

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
      inputs.nur.overlay
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    inherit username homeDirectory;

    sessionVariables = {
      QT_XCB_GL_INTEGRATION = "none"; # kde-connect
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      NIXOS_OZONE_WL = "1";
    };

    sessionPath = ["$HOME/.local/bin"];
  };

  services = {
    kdeconnect = {
    enable = true;
    indicator = true;
   };
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
