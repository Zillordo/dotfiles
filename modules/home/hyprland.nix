{ inputs, pkgs, ... }:
let
  split-monitor-workspaces = inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    # plugins = [split-monitor-workspaces];
    # https://github.com/Duckonaut/split-monitor-workspaces/pull/54 split-monitor-workspaces issue

    settings = {
      plugin = {
        hyprbars = {
          bar_color = "rgb(2a2a2a)";
          bar_height = 28;
          col_text = "rgba(ffffffdd)";
          bar_text_size = 11;
          bar_text_font = "Ubuntu Nerd Font";

          buttons = {
            button_size = 0;
            "col.maximize" = "rgba(ffffff11)";
            "col.close" = "rgba(ff111133)";
          };
        };
      };
    };
  };

  xdg.configFile.hypr = {
    source = ../../dotfiles/hypr;
    recursive = true;
  };

  xdg.desktopEntries."org.gnome.Settings" = {
    name = "Settings";
    comment = "Gnome Control Center";
    icon = "org.gnome.Settings";
    exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome.gnome-control-center}/bin/gnome-control-center";
    categories = [ "X-Preferences" ];
    terminal = false;
  };

  home.packages = with pkgs; [
    swww
    pywal
    networkmanagerapplet
    pavucontrol
    htop
  ];
}
