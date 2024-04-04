{ inputs, pkgs, asztal, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.";
      window_padding_width = "3 5";
    };
    shellIntegration = {
      enableZshIntegration = true;
    };
  };
}
