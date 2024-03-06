{ ... }:
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

  xdg.configFile.nvim = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
