{ pkgs, config, inputs, ... }: {
  programs.neovim = {
    enable = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = true;
    withNodeJs = true;
    withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      telescope-nvim
      telescope-fzy-native-nvim
      undotree
      which-key-nvim
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp-zsh
      cmp-nvim-lua
      nvim-lspconfig
      cmp-nvim-lsp
      none-ls-nvim
    ];
  };

  home.packages = with pkgs; [
    git
    gcc
    gnumake
    unzip
    wget
    curl
    ripgrep
    fd
    fzf
    cargo
    lazygit
    luajitPackages.jsregexp
    #nix
    statix
    deadnix
    alejandra
    nil
  ];

  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/dotfiles/dotfiles/nvim";
      recursive = true;
    };
  };
}
