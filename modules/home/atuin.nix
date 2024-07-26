{ config, ... }: {
  programs.atuin = {
    enable = true;
    settings = {
      # Uncomment this to use your instance
      # sync_address = "https://majiy00-shell.fly.dev";
    };
  };
}
