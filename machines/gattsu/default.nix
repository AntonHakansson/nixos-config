{ ... }: {
  imports = [ ./hardware.nix ];

  networking.hostName = "gattsu";
  networking.hostId = "96a2d6d5";

  hakanssn = {
    stateVersion = "21.11";
    core = {
      zfs = {
        encrypted = true;
        rootDataset = "rpool/local/root";
      };
      emacs.enable = true;
    };
    development = {
      enable = true;
      git.email = "anton.hakansson98@gmail.com";
    };
    graphical = {
      enable = true;
      syncthing.enable = true;
      games.enable = true;
      media.anki.enable = true;

      sway.enable = false;
      hyprland.enable = true;
    };
  };

  # virtualisation.libvirtd.enable = true;
  # users.users.hakanssn.extraGroups = [ "libvirtd" ];
  # hakanssn.core.zfs.systemCacheLinks = [ "/var/lib/libvirt/" ];

  # Disable auto-upgrade
  hakanssn.graphical.theme.autoSwitchTheme = false;
  system.autoUpgrade.enable = false;

  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;
}
