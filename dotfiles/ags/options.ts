import { type BarWidget } from "widget/bar/Bar";
import { opt, mkOptions } from "lib/option";

const options = mkOptions(OPTIONS, {
  autotheme: opt(true),

  wallpaper: opt(`/home/${USER}/Documents/Wallpapers/default.jpg`, {
    persistent: true,
  }),

  theme: {
    dark: {
      primary: {
        bg: opt("#51a4e7"),
        fg: opt("#141414"),
      },
      error: {
        bg: opt("#e55f86"),
        fg: opt("#141414"),
      },
      bg: opt("#171717"),
      fg: opt("#eeeeee"),
      widget: opt("#eeeeee"),
      border: opt("#eeeeee"),
    },
    light: {
      primary: {
        bg: opt("#426ede"),
        fg: opt("#eeeeee"),
      },
      error: {
        bg: opt("#b13558"),
        fg: opt("#eeeeee"),
      },
      bg: opt("#fffffa"),
      fg: opt("#080808"),
      widget: opt("#080808"),
      border: opt("#080808"),
    },

    blur: opt(0),
    scheme: opt<"dark" | "light">("dark"),
    widget: { opacity: opt(94) },
    border: {
      width: opt(2),
      opacity: opt(96),
    },

    shadows: opt(true),
    padding: opt(8),
    spacing: opt(3),
    radius: opt(6),
  },

  transition: opt(200),

  font: {
    size: opt(12),
    name: opt("Ubuntu Nerd Font"),
  },

  bar: {
    flatButtons: opt(true),
    position: opt<"top" | "bottom">("top"),
    corners: opt(true),
    layout: {
      start: opt<BarWidget[]>([
        "workspaces",
        "taskbar",
        "expander",
        "messages",
      ]),
      center: opt<BarWidget[]>(["date"]),
      end: opt<BarWidget[]>([
        "media",
        "expander",
        "systray",
        "screenrecord",
        "system",
        "battery",
        "powermenu",
      ]),
    },
    date: {
      format: opt("%H:%M - %A %e.%m"),
      action: opt(() => App.toggleWindow("datemenu")),
    },
    battery: {
      bar: opt<"hidden" | "regular" | "whole">("regular"),
      charging: opt("#00D787"),
      percentage: opt(true),
      blocks: opt(7),
      width: opt(50),
      low: opt(30),
    },
    workspaces: {
      workspaces: opt(7),
    },
    taskbar: {
      iconSize: opt(0),
      monochrome: opt(true),
      exclusive: opt(false),
    },
    messages: {
      action: opt(() => App.toggleWindow("datemenu")),
    },
    systray: {
      ignore: opt(["KDE Connect Indicator", "spotify-client"]),
    },
    media: {
      monochrome: opt(true),
      preferred: opt("spotify"),
      direction: opt<"left" | "right">("right"),
      format: opt("{artists} - {title}"),
      length: opt(40),
    },
    powermenu: {
      monochrome: opt(false),
      action: opt(() => App.toggleWindow("powermenu")),
    },
  },

  overview: {
    scale: opt(9),
    workspaces: opt(7),
    monochromeIcon: opt(false),
  },

  powermenu: {
    sleep: opt("systemctl suspend"),
    reboot: opt("systemctl reboot"),
    logout: opt("pkill Hyprland"),
    shutdown: opt("shutdown now"),
    layout: opt<"line" | "box">("line"),
    labels: opt(false),
  },

  quicksettings: {
    avatar: {
      image: opt(`/var/lib/AccountsService/icons/${Utils.USER}`),
      size: opt(70),
    },
    width: opt(380),
    position: opt<"left" | "center" | "right">("right"),
    networkSettings: opt("nm-connection-editor"),
    media: {
      monochromeIcon: opt(false),
      coverSize: opt(100),
    },
  },

  datemenu: {
    position: opt<"left" | "center" | "right">("center"),
  },

  osd: {
    progress: {
      vertical: opt(true),
      pack: {
        h: opt<"start" | "center" | "end">("end"),
        v: opt<"start" | "center" | "end">("center"),
      },
    },
    microphone: {
      pack: {
        h: opt<"start" | "center" | "end">("center"),
        v: opt<"start" | "center" | "end">("end"),
      },
    },
  },

  notifications: {
    position: opt<Array<"top" | "bottom" | "left" | "right">>(["top", "right"]),
    blacklist: opt(["Spotify"]),
    width: opt(440),
  },

  hyprland: {
    gaps: opt(2.4),
    inactiveBorder: opt("333333ff"),
    gapsWhenOnly: opt(false),
  },
});

globalThis["options"] = options;
export default options;
