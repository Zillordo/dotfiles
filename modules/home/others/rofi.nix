{ pkgs, config, ... }: {
  home.packages = with pkgs; [ rofi-emoji ];

  programs.rofi = {
    enable = true;
    theme =
      "${config.home.homeDirectory}/.config/dotfiles/dotfiles/rofi-themes/main.rasi";

    package = pkgs.rofi-wayland.override { plugins = [ pkgs.rofi-emoji ]; };
  };
}
