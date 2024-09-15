{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;
    # Open ports in the firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
    # Open ports in the firewall for Steam Local Network Game Transfers
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [ mangohud protonup ];

  environment.sessionVariables = {
    STEAM_COMPAT_CLIENT_INSTALL_PATH =
      "/home/allank/.steam/root/compatibilitytools.d";
  };
}
