{ inputs, system, ... }: {
  imports = [ ./brave.nix ./firefox.nix ];
  home.packages = [ inputs.zen-browser.packages."${system}".specific ];
}
