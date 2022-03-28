{ ... }: {
  imports = [ ./hardware.nix ];

  networking.hostId = "258f6cbd";

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
