{ config, lib, pkgs, ... }:

{
  config =
    let pinentryFlavor = if config.hakanssn.graphical.enable then "gnome3" else "tty";
    in {
      hakanssn.core.zfs.homeDataLinks = [{
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
