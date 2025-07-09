{ ... }: {
  imports = [ ./hardware.nix ];

  networking.hostName = "falconia";
  networking.hostId = "06ad334e";

  hakanssn = {
    stateVersion = "21.11";
    core = {
      zfs = {
        encrypted = false;
        rootDataset = "rpool/local/root";
      };
    };
    development = {
      enable = true;
      git.email = "anton.hakansson98@gmail.com";
    };
    services = {
      # calibre.enable = true;
      nginx.hosts = [{
        fqdn = "hakanssn.com";
        options = { };
      }];
      mail.enable = true;
      # nextcloud.enable = true;
      syncthing.enable = true;
      hakanssn-webserver.enable = true;
    };
  };

  services.smartd.enable = false; # no SMART enabled devices
}
