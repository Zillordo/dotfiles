# link to nix dev env templates https://github.com/the-nix-way/dev-templates
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
