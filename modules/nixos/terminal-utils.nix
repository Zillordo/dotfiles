{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    fnm
    lazygit
    git-ignore
    ripgrep
    jq
    fzf
    bat
    bun
  ];
}
