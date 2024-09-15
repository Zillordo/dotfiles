{ ... }: {
  boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "ntfs" ];
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
  };
}

