{
  imports = [ ./open-ssh.nix ./tlp.nix ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable automatic login for the user
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "allank";
}
