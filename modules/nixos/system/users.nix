{ pkgs, ... }:

{
  programs.zsh.enable = true;
  users.users.allank = {
    isNormalUser = true;
    description = "allank";
    extraGroups =
      [ "networkmanager" "input" "wheel" "video" "audio" "tss" "docker" ];
    shell = pkgs.zsh;
  };

  # Change runtime directory size
  services.logind.extraConfig = "RuntimeDirectorySize=8G";
}
