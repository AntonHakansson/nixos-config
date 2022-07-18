{ config, lib, ... }:

{
  options.hakanssn.services.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.hakanssn.services.syncthing.enable {
    hakanssn.core.zfs.systemDataLinks = [ "/var/lib/syncthing" ];

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384";

      dataDir = "/var/lib/syncthing";
      configDir = "/var/lib/syncthing/.config";
    };

    hakanssn.services.nginx.hosts = [{
      fqdn = "syncthing.hakanssn.com";
      basicProxy = "http://localhost:8384";
      options.basicAuthFile =
        config.age.secrets."passwords/services/syncthing-basic-auth".path;
    }];

    age.secrets."passwords/services/syncthing-basic-auth" = {
      file = ../../../secrets/passwords/services/syncthing-basic-auth.age;
      owner = "nginx";
    };
  };
}
