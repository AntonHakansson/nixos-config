{ ... }: {
  imports = [ ./hardware.nix ];

  networking.hostId = "96a2d6d5";

  asdf = {
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
    };
  };
}
