{ pkgs, config, inputs, ... }: {
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = true;
    withNodeJs = true;
    withPython3 = true;

    extraPackages = with pkgs; [
      git
      gcc
      gnumake
      unzip
      wget
      curl
      tree-sitter
      ripgrep
      fd
      fzf
      cargo
      lazygit
      luajitPackages.jsregexp
    ];
  };

  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/dotfiles/dotfiles/nvim";
      recursive = true;
    };
  };
}
