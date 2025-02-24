{ inputs, system, ... }: {
  imports = [ ./atuin.nix ./starship.nix ./zsh.nix ];
  home.packages = [ inputs.ghostty.packages."${system}".default ];
}
