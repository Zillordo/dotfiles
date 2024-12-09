{
  virtualisation.docker = { enable = true; };

  networking.firewall = {
    allowedTCPPorts = [ 80 5432 8080 ];
    enable = true;
    extraCommands = ''
      iptables -I INPUT 1 -s 172.17.0.0/16 -p tcp -d 172.17.0.1 -j ACCEPT
      iptables -I INPUT 2 -s 172.17.0.0/16 -p udp -d 172.17.0.1 -j ACCEPT
    '';
  };
}

