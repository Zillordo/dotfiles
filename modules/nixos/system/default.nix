{ ... }: {
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
  };

  # logind
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=ignore
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable automatic login for the user
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "allank";

  # Workaround for gnome autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

}
