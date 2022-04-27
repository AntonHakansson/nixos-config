# Allow system to notify by email on critical failures (smartd, etc.)
{ config, lib, pkgs, ... }:

{
  programs.msmtp = {
    enable = lib.mkDefault true;
    accounts.default = {
      auth = true;
      from = "postbot@hakanssn.com";
      host = "mail.hakanssn.com";
      passwordeval = "${pkgs.coreutils}/bin/cat ${
          config.age.secrets."passwords/services/mail/ssmtp-webmaster-pass".path
        }";
      port = 465;
      tls = true;
      tls_starttls = false;
      tls_trust_file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      user = "postbot@hakanssn.com";
    };
    setSendmail = !config.asdf.services.mail.enable;
  };

  age.secrets."passwords/services/mail/ssmtp-webmaster-pass".file =
    ../../../secrets/passwords/services/mail/ssmtp-webmaster-pass.age;
}
