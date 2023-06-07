{ config, lib, pkgs, ... }:

{
  options.hakanssn.services.nginx = {
    enable = lib.mkOption {
      readOnly = true;
      default = (builtins.length config.hakanssn.services.nginx.hosts) > 0;
    };
    hosts = lib.mkOption {
      default = [ ];
      example = [{
        fqdn = "data.hakanssn.com";
        options = {
          default = true;
          root = "/srv/data";
          locations = {
            "/".extraConfig = ''
              autoindex on;
            '';
            "/public".extraConfig = ''
              autoindex on;
              auth_basic off;
            '';
          };
        };
      }];
    };
  };

  config = lib.mkIf config.hakanssn.services.nginx.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    security.acme = {
      certs."hakanssn.com" = {
        extraDomainNames = [ "hakanssn.com" ];
      };
      defaults.email = "webmaster@hakanssn.com";
      acceptTerms = true;
    };
    hakanssn.core.zfs.systemDataLinks = [ "/var/lib/acme" ];
    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      virtualHosts = builtins.listToAttrs (map
        (elem: {
          name = elem.fqdn;
          value = {
            forceSSL = true;
            enableACME = true; # let's encrypt
            locations."/" = lib.mkIf (builtins.hasAttr "basicProxy" elem) {
              proxyPass = elem.basicProxy;
              extraConfig = ''
                proxy_set_header X-Forwarded-Ssl on;
              '' + (elem.extraProxySettings or "");
            };
          } // (elem.options or { });
        })
        config.hakanssn.services.nginx.hosts);
    };
    users.users = {
      nginx.extraGroups = [ "acme" ];
      acme.uid = 999;
    };
    users.groups.acme.gid = 999;
  };
}
