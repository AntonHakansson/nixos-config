{ config, lib, pkgs, ... }:

{
  options.hakanssn.services.nextcloud.enable = lib.mkEnableOption "nextcloud";
  config = lib.mkIf config.hakanssn.services.nextcloud.enable {
    hakanssn.core.zfs.systemDataLinks = [
      {
        directory = "/var/lib/nextcloud";
        user = "nextcloud";
      }
      {
        directory = "/var/lib/postgresql";
        user = "postgres";
      }
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1u"
    ];

    services = {
      nextcloud = {
        enable = true;
        hostName = "nextcloud.hakanssn.com";
        https = true;

        home = "${config.hakanssn.dataPrefix}/var/lib/nextcloud";
        autoUpdateApps.enable = true;
        autoUpdateApps.startAt = "05:00:00";

        package = pkgs.nextcloud25;
        config = {
          # Further forces Nextcloud to use HTTPS
          overwriteProtocol = "https";

          dbuser = "nextcloud";
          dbname = "nextcloud";
          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          adminuser = "admin";
          adminpassFile =
            config.age.secrets."passwords/services/nextcloud-admin".path;
        };
      };
      nginx.virtualHosts."nextcloud.hakanssn.com" = {
        forceSSL = true;
        enableACME = true;
      };
      postgresql = {
        enable = true;
        dataDir =
          "${config.hakanssn.dataPrefix}/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [{
          name = "nextcloud";
          ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
        }];
      };
    };
    age.secrets."passwords/services/nextcloud-admin" = {
      file = ../../../secrets/passwords/services/nextcloud-admin.age;
      owner = "nextcloud";
    };
    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
