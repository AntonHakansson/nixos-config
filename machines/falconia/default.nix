{ ... }: {
  imports = [ ./hardware.nix ];

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
      nginx.hosts = [{
        fqdn = "hakanssn.com";
        options = { };
      }];
      mail.enable = true;
      nextcloud.enable = true;
      syncthing.enable = true;
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP =
      [ "127.0.0.0/8" "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "8.8.8.8" ];
  };

  services.smartd.enable = false; # no SMART enabled devices
}
