{ config, lib, pkgs, ... }:

{
  options.hakanssn.services.mail.enable = lib.mkEnableOption "mail";

  config = lib.mkIf config.hakanssn.services.mail.enable {
    hakanssn.core.zfs.systemCacheLinks = [
      {
        directory = "/var/lib/dhparams";
        group = "dhcpcd";
      }
      {
        directory = "/var/lib/dovecot";
        user = "dovecot2";
      }
      {
        directory = "/var/lib/knot-resolver";
        user = "knot-resolver";
      }
      {
        directory = "/var/lib/opendkim";
        user = "opendkim";
      }
      {
        directory = "/var/lib/postfix";
        user = "postfix";
      }
      {
        directory = "/var/lib/redis-rspamd";
        user = "redis-rspamd";
      }
    ];

    hakanssn.core.zfs.systemDataLinks = [
      {
        directory = "/var/vmail";
        user = "virtualMail";
        group = "virtualMail";
      }
      {
        directory = "/var/dkim";
        user = "opendkim";
        group = "opendkim";
      }
    ];

    services.nginx.virtualHosts.${config.mailserver.fqdn}.enableACME = true;

    mailserver = {
      enable = true;
      stateVersion = 3;
      fqdn = "mail.hakanssn.com";
      domains = [ "hakanssn.com" ];

      # Reference the existing ACME configuration created by nginx
      x509.useACMEHost = config.mailserver.fqdn;

      # A list of all login accounts. To create the password hashes, use
      # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
      accounts = {
        "anton@hakanssn.com" = {
          hashedPasswordFile =
            config.age.secrets."passwords/services/mail/anton@hakanssn.com".path;
        };
      };

      indexDir = "${config.hakanssn.cachePrefix}/var/lib/dovecot/indices";

      # whether to scan inbound emails for viruses (note that this requires at least
      # 1 Gb RAM for the server. Without virus scanning 256 MB RAM should be plenty)
      virusScanning = false;
    };

    # IPv6 privacy address extention make mail originate from one of
    # the temporary addresses breaking rDNS expectations.
    networking.tempAddresses = "disabled";

    age.secrets = {
      "passwords/services/mail/anton@hakanssn.com".file =
        ../../../secrets/passwords/services/mail/anton_at_hakanssn.com.age;
    };
  };
}
