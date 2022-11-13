{ config, lib, pkgs, ... }:

let cfg = config.hakanssn.services.calibre;
in {
  options.hakanssn.services.calibre = {
    enable = lib.mkEnableOption "calibre-web";
    port = lib.mkOption {
      description = lib.mdDoc "The port under which calibre-web runs.";
      type = lib.types.port;
      default = 8083;
    };
  };

  config = lib.mkIf config.hakanssn.services.calibre.enable {
    hakanssn.core.zfs.systemDataLinks =
      [ "/var/lib/calibre-server" "/var/lib/calibre-web" ];

    services.calibre-web = {
      enable = true;
      listen.port = cfg.port;
      options = {
        calibreLibrary = "/var/lib/calibre-server/library";
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };

    services.nginx.virtualHosts."calibre.hakanssn.com" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://[::1]:${toString cfg.port}";
          extraConfig = ''
            client_max_body_size 500M;
          '';
        };
      };
    };
  };
}
