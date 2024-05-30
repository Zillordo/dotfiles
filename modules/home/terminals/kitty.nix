{ ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "1";
      window_padding_width = "3 5";
    };
    shellIntegration = {
      enableZshIntegration = true;
    };
  };
}
