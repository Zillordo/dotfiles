{ pkgs, inputs, system, ... }: {
  imports = [ ./brave.nix ];
  home.packages = [ inputs.zen-browser.packages."${system}".specific ];
}
