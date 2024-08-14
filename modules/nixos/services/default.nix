{
  imports = [ ./open-ssh.nix ./tlp.nix ];

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable automatic login for the user
    xserver.displayManager.autoLogin.enable = true;
    xserver.displayManager.autoLogin.user = "allank";

    automatic-timezoned.enable = true;

    avahi = {
      enable = true;
      nssmdns = true;
      publish.enable = true;
      publish.addresses = true;
      publish.workstation = true;
    };
  };
}
