let
  lang = icon: color: {
    symbol = icon;
    format = "[$symbol ](${color})";
  };
  os = icon: fg: "[${icon} ](fg:${fg})";
  pad = {
    left = "";
    right = "";
  };
in {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = builtins.concatStringsSep "" [
        "$nix_shell"
        "$os"
        "$directory"
        "$container"
        "$git_branch $git_status"
        "$python"
        "$nodejs"
        "$lua"
        "$rust"
        "$java"
        "$c"
        "$golang"
        "$cmd_duration"
        "$status"
        "$line_break"
        "[❯](bold purple)"
        "\${custom.space}"
      ];
      custom.space = {
        when = "! test $env";
        format = "  ";
      };
      continuation_prompt = "∙  ┆ ";
      line_break = { disabled = false; };
      status = {
        symbol = "✗";
        not_found_symbol = "󰍉 Not Found";
        not_executable_symbol = " Can't Execute E";
        sigint_symbol = "󰂭 ";
        signal_symbol = "󱑽 ";
        success_symbol = "";
        format = "[$symbol](fg:red)";
        map_symbol = true;
        disabled = false;
      };
      cmd_duration = {
        min_time = 1000;
        format = "[$duration ](fg:yellow)";
      };
      nix_shell = {
        disabled = false;
        format =
          "[${pad.left}](fg:white)[ ](bg:white fg:black)[${pad.right}](fg:white) ";
      };
      container = {
        symbol = " 󰏖";
        format = "[$symbol ](yellow dimmed)";
      };
      directory = {
        format = " (fg:bright-black)[$path](fg:white)(fg:bright-black)";
        truncation_length = 6;
        truncation_symbol = "~/󰇘/";
      };
      # directory.substitutions = {
      #   "Documents" = "󰈙 ";
      #   "Downloads" = " ";
      #   "Music" = " ";
      #   "Pictures" = " ";
      #   "Videos" = " ";
      #   "Projects" = "󱌢 ";
      #   "School" = "󰑴 ";
      #   "GitHub" = "";
      #   ".config" = " ";
      #   "Vault" = "󱉽 ";
      # };
      git_branch = {
        symbol = "";
        style = "";
        format = "[ $symbol $branch](fg:purple)(:$remote_branch)";
      };
      os = {
        disabled = false;
        format = "$symbol";
      };
      os.symbols = {
        Arch = os "" "bright-blue";
        Debian = os "" "red)";
        EndeavourOS = os "" "purple";
        Fedora = os "" "blue";
        NixOS = os "" "blue";
        openSUSE = os "" "green";
        SUSE = os "" "green";
        Ubuntu = os "" "bright-purple";
      };
      python = lang "" "yellow";
      nodejs = lang " " "yellow";
      lua = lang "󰢱" "blue";
      rust = lang "" "red";
      java = lang "" "red";
      c = lang "" "blue";
      golang = lang "" "blue";
    };
  };
}
