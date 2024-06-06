{ pkgs, ... }:
{
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THREASH_BAT0 = 40;
      STOP_CHARGE_THREASH_BAT0 = 80;
    };
  };
}
