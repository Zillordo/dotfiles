{ pkgs, config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
  };

  xdg.configFile = {
    nvim = {
      source =
        config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/.config/dotfiles/dotfiles/nvim";
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    lazygit
    luajitPackages.jsregexp
  ];
}
