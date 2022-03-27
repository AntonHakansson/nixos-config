{ config, lib, pkgs, ... }:

{
  options.asdf.services.mail.enable = lib.mkEnableOption "mail";

  config = lib.mkIf config.asdf.services.mail.enable {
    asdf.core.zfs.systemCacheLinks = [
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

    asdf.core.zfs.systemDataLinks = [
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

    mailserver = {
      enable = true;
      fqdn = "mail.hakanssn.com";
      domains = [ "hakanssn.com" ];

      # A list of all login accounts. To create the password hashes, use
      # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
      loginAccounts = {
        "anton@hakanssn.com" = {
          hashedPassword =
            "$2y$05$eG.yuSDKHx6aZZZhWbZ8Uuyr5yNWtTWR8DA1dZBn/th4kzyoYMFrS";
        };
        "webmaster@hakanssn.com" = {
          hashedPassword =
            "$2y$05$KxHSaRSluJtNYeQccl5T0.ErdRZfn3qIa.AqNnAMxa19QdNDx6i9G";
        };
      };

      indexDir = "${config.asdf.cachePrefix}/var/lib/dovecot/indices";

      # Enable POP3 for retrieving mail with gmail because it does not support imap
      # When configuring POP3 on gmail client use SSL on port 995
      enablePop3Ssl = true;

      # Use Let's Encrypt certificates. Note that this needs to set up a stripped
      # down nginx and opens port 80.
      certificateScheme = 3;

      # whether to scan inbound emails for viruses (note that this requires at least
      # 1 Gb RAM for the server. Without virus scanning 256 MB RAM should be plenty)
      virusScanning = false;
    };
  };
}
