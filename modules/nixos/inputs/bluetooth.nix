{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  environment.systemPackages = with pkgs; with gnome; [ gnome.gnome-bluetooth ];
}

