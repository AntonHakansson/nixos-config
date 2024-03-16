{ config, lib, pkgs, ... }:

{
  config =
    let pinentryFlavor = if config.hakanssn.graphical.enable then "qt" else "tty";
    in {
      hakanssn.core.zfs.homeDataLinks = [{
        directory = ".gnupg";
        mode = "0700";
      }];

      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs."pinentry-${pinentryFlavor}";
      };
      home-manager.users.hakanssn = { lib, ... }: {
        programs.gpg.enable = true;
        services.gpg-agent = {
          enable = true;
          defaultCacheTtl = 7200;
          maxCacheTtl = 99999;
          pinentryPackage = pkgs."pinentry-${pinentryFlavor}";
        };
      };
    };
}
