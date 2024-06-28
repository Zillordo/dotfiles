# link to nix dev env templates https://github.com/the-nix-way/dev-template
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
