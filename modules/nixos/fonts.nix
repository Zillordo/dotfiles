{ pkgs, ... }:

{
  # Fonts
  fonts.packages = with pkgs; [
    fira-code
    font-awesome
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
}
