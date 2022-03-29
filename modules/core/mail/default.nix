# Allow system to notify by email on critical failures (smartd, etc.)
{ config, lib, pkgs, ... }:

{
  services.ssmtp = {
    enable = lib.mkDefault true;
    authUser = "postbot@hakanssn.com";
    authPassFile =
      config.age.secrets."passwords/services/mail/ssmtp-webmaster-pass".path;
    domain = "hakanssn.com";
    hostName = "mail.hakanssn.com:465";
    useTLS = true;
    setSendmail = !config.asdf.services.mail.enable;
  };

  age.secrets."passwords/services/mail/ssmtp-webmaster-pass".file =
    ../../../secrets/passwords/services/mail/ssmtp-webmaster-pass.age;
}
