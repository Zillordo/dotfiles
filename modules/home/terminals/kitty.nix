{ ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.7";
      window_padding_width = "3 5";
    };
    shellIntegration = {
      enableZshIntegration = true;
    };
  };
}
