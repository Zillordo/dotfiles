{ inputs, pkgs, ... }:
let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
  plugins = inputs.hyprland-plugins.packages.${pkgs.system};
  split-monitor-workspaces =
    inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces;

  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  rofi = "${pkgs.rofi-wayland}/bin/rofi";

  terminal = "kitty";
  browser = "firefox";
  mod = "SUPER";
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprland;
    systemd.enable = true;
    xwayland.enable = true;
    plugins = with plugins;
      [
        # hyprexpo
        # hyprbars
        # borderspp
      ];

    settings = {
      exec-once =
        [ "ags -b hypr" "hyprctl setcursor Qogir 24" "transmission-gtk" ];

      general = {
        layout = "dwindle";
        resize_on_border = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 1;
      };

      input = {
        follow_mouse = 1;
        mouse_refocus = true;
        touchpad = {
          natural_scroll = "yes";
          disable_while_typing = true;
          drag_lock = true;
        };
        sensitivity = 0;
        float_switch_override_focus = 2;
      };

      binds = { allow_workspace_cycles = true; };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
      };

      windowrule = let f = regex: "float, ^(${regex})$";
      in [
        (f "org.gnome.Calculator")
        (f "org.gnome.Nautilus")
        (f "pavucontrol")
        (f "nm-connection-editor")
        (f "blueberry.py")
        (f "org./nome.design.Palette")
        (f "Color Picker")
        (f "xdg-desktop-portal")
        (f "xdg-desktop-portal-gnome")
        (f "transmission-gtk")
        (f "com.github.Aylur.ags")
        "workspace 7, title:Spotify"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        mvfocus = binding "${mod}" "movefocus";
        ws = binding "${mod}" "workspace";
        resizeactive = binding "${mod} CTRL" "resizeactive";
        mvwindow = binding "${mod} SHIFT" "movewindow";
        mvtows = binding "${mod} SHIFT" "movetoworkspace";
        e = "exec, ags -b hypr";
        arr = [ 1 2 3 4 5 6 7 8 9 ];

      in [
        "${mod} SHIFT, B,  ${e} quit; ags -b hypr"
        "${mod}, R,       exec, ${rofi} -show drun -show-icons"
        "${mod}, Tab,     ${e} -t overview"
        ",XF86PowerOff,  ${e} -r 'powermenu.shutdown()'"
        "ALT SHIFT, R,   ${e} -r 'recorder.start()'"
        ",Print,         ${e} -r 'recorder.screenshot()'"
        "SHIFT,Print,    ${e} -r 'recorder.screenshot(true)'"
        "${mod}, Return, exec, ${terminal}"
        "${mod}, B, exec, ${browser}"
        "${mod} CTRL, B, exec, ${browser} --private-window"
        "${mod} SHIFT, P, ${e} -t powermenu"
        "${mod}, N, ${e} -t datemenu"
        "${mod}, Comma, ${e} -t settings-dialog"

        "ALT, Tab, focuscurrentorlast"
        "CTRL ALT, Delete, exit"
        "${mod}, C, killactive"
        "${mod}, F, togglefloating"
        "${mod}, G, fullscreen, 1"
        "${mod}, SPACE, togglesplit"

        # "SUPER, grave, hyprexpo:expo, toggle"

        (mvfocus "k" "u")
        (mvfocus "j" "d")
        (mvfocus "l" "r")
        (mvfocus "h" "l")
        (ws "left" "e-1")
        (ws "right" "e+1")
        (mvtows "left" "e-1")
        (mvtows "right" "e+1")
        (resizeactive "k" "0 -20")
        (resizeactive "j" "0 20")
        (resizeactive "l" "20 0")
        (resizeactive "h" "-20 0")
        (mvwindow "k" "u")
        (mvwindow "j" "d")
        (mvwindow "l" "r")
        (mvwindow "h" "l")
      ] ++ (map (i: ws (toString i) (toString i)) arr)
      ++ (map (i: mvtows (toString i) (toString i)) arr);

      bindle = [
        ",XF86MonBrightnessUp,   exec, ${brightnessctl} set +5%"
        ",XF86MonBrightnessDown, exec, ${brightnessctl} set  5%-"
        ",XF86AudioRaiseVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ",XF86AudioLowerVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ",XF86AudioMute,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ toggle"
      ];

      bindl = [
        ",XF86AudioPlay,    exec, ${playerctl} play-pause"
        ",XF86AudioStop,    exec, ${playerctl} pause"
        ",XF86AudioPause,   exec, ${playerctl} pause"
        ",XF86AudioPrev,    exec, ${playerctl} previous"
        ",XF86AudioNext,    exec, ${playerctl} next"
        ",XF86AudioMicMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
      ];

      bindm =
        [ "${mod}, mouse:273, resizewindow" "${mod}, mouse:272, movewindow" ];

      decoration = {
        drop_shadow = "yes";
        shadow_range = 8;
        shadow_render_power = 2;
        "col.shadow" = "rgba(00000044)";

        dim_inactive = false;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = "on";
          noise = 1.0e-2;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
        };
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(232323)";
          workspace_method = "center current";
          enable_gesture = true;
          gesture_distance = 300;
          gesture_positive = false;
        };
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
}
