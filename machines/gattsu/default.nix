{ ... }: {
  imports = [ ./hardware.nix ];

  networking.hostId = "96a2d6d5";

  system.autoUpgrade.enable = false;
  nixpkgs.config.permittedInsecurePackages = [ "python3.10-mistune-0.8.4" ];

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
    };
  };
}
