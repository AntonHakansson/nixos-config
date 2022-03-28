{ config, lib, pkgs, ... }:

{
  config =
    let pinentryFlavor = if config.asdf.graphical.enable then "gtk2" else "tty";
    in {
      asdf.core.zfs.homeDataLinks = [{
        directory = ".gnupg";
        mode = "0700";
      }];

      programs.gnupg.agent = {
        enable = true;
        pinentryFlavor = pinentryFlavor;
      };
      home-manager.users.hakanssn = { lib, ... }: {
        programs.gpg.enable = true;
        services.gpg-agent = {
          enable = true;
          defaultCacheTtl = 7200;
          maxCacheTtl = 99999;
          pinentryFlavor = pinentryFlavor;
        };
      };
    };
}
