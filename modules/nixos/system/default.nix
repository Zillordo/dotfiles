{ pkgs, ... }: {
  imports = [
    ./boot.nix
    ./fonts.nix
    ./i18n.nix
    ./netwok.nix
    ./nix-helper.nix
    ./timezone.nix
    ./users.nix
  ];

  documentation.nixos.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  # dconf
  programs.dconf.enable = true;

  # services
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    printing.enable = true;
    flatpak.enable = true;

    # logind
    logind.extraConfig = ''
      HandlePowerKey=ignore
      HandleLidSwitch=suspend
      HandleLidSwitchExternalPower=ignore
    '';

    # Enable automatic login for the user
    displayManager.autoLogin = {
      enable = true;
      user = "allank";
    };
  };

  # Workaround for gnome autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

}
