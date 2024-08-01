{ pkgs, ... }: {
  imports = [ ./hardware.nix ];

  networking.hostName = "rickert";
  networking.hostId = "258f6cbd";

  hakanssn = {
    stateVersion = "21.11";
    core = {
      zfs = {
        encrypted = true;
        rootDataset = "rpool/local/root";
      };
      emacs.enable = true;
      network.enable = true;
    };
    development = {
      enable = true;
      git.email = "anton.hakansson98@gmail.com";
    };
    graphical = {
      enable = true;
      laptop = true;
      syncthing.enable = true;
      media.anki.enable = true;
      plasma.enable = true;
    };
  };

  # Disable auto-upgrade
  system.autoUpgrade.enable = false;
}
