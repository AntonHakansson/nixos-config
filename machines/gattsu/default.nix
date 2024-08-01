{ pkgs, ... }: {
  imports = [ ./hardware.nix ];

  networking.hostName = "gattsu";
  networking.hostId = "96a2d6d5";

  hakanssn = {
    stateVersion = "21.11";
    core = {
      zfs = {
        encrypted = true;
        rootDataset = "rpool/local/root";
        backups  = [
          {
            path = "rpool/safe/data";
            remotePath = "rpool/recv/gattsu/safe/data";
            location = "localhost";
          }];
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
      media.anki.enable = true;
      river.enable = true;
    };
  };

  # Virtual machines
  # virtualisation.libvirtd.enable = true;
  # environment.systemPackages = [ pkgs.virt-manager ];
  # users.users.hakanssn.extraGroups = [ "libvirtd" ];
  # hakanssn.core.zfs.systemCacheLinks = [ "/var/lib/libvirt/" ];

  # Distrobox
  virtualisation.podman.enable = true;
  environment.systemPackages = [ pkgs.distrobox ];

  # Disable auto-upgrade
  system.autoUpgrade.enable = false;

  # Enable OpenTabletDriver
  # hardware.opentabletdriver.enable = true;
  hakanssn.core.zfs.homeCacheLinks = [ ".config/OpenTabletDriver/" ];
}
